<?php
/**
 * File containing the expDocContributorMerge class.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

/**
 * Merges duplicate contributor objects (exp_doc_contributor) into one: every relation to a duplicate, in every
 * class and every version (object relation and relation list attributes such as written_by, last_updated_by,
 * maintainers, contributors and a comment's author, and the rows of ezcontentobject_link), points at the canonical
 * contributor afterwards. Attributes are changed through the kernel (content, store), so the datatype keeps the link
 * table of that version right; link rows no attribute holds are moved with the object's relation methods.
 *
 * The canonical contributor takes the profile (bio, picture, link ...) of a duplicate where its own is empty, in a new
 * published version. Texts such as a comment's author_name are never touched. Only when no relation points at a
 * duplicate any more, it goes to the trash (and with $purge is removed from it), and each of its addresses becomes a
 * custom alias of the canonical contributor that redirects (301) there. The view caches of the changed objects and of
 * both contributors are cleared, nothing else.
 */
class expDocContributorMerge
{
    const CONTRIBUTOR_CLASS = 'exp_doc_contributor';

    /** @var bool */
    protected $dryRun;

    /** @var bool */
    protected $purge;

    /** @var array the report */
    public $report = array( 'into' => null, 'from' => array(), 'attributes' => array(), 'links' => 0, 'objects' => array(),
                            'profile' => array(), 'remaining' => 0, 'trashed' => array(), 'purged' => array(), 'redirects' => array(),
                            'errors' => array() );

    /**
     * @param bool $dryRun count and list only
     * @param bool $purge remove the trashed duplicates from the trash too
     */
    public function __construct( $dryRun = true, $purge = false )
    {
        $this->dryRun = (bool)$dryRun;
        $this->purge = (bool)$purge;
    }

    /**
     * A contributor by node id, object id ("object:<id>"), remote id (of the object or of its node), or address.
     *
     * @param string $reference
     * @return eZContentObject|null
     */
    public static function resolve( $reference )
    {
        $reference = trim( (string)$reference );
        $object = null;
        if ( preg_match( '/^object:(\d+)$/', $reference, $m ) )
            $object = eZContentObject::fetch( (int)$m[1] );
        else if ( ctype_digit( $reference ) )
        {
            $node = eZContentObjectTreeNode::fetch( (int)$reference );
            $object = $node instanceof eZContentObjectTreeNode ? $node->object() : null;
        }
        else
        {
            $object = eZContentObject::fetchByRemoteID( $reference );
            if ( !$object instanceof eZContentObject && ( $node = eZContentObjectTreeNode::fetchByRemoteID( $reference ) ) )
                $object = $node->object();
            if ( !$object instanceof eZContentObject )
            {
                // an address: https://host/doc/contributors/name, /contributors/name or contributors/name
                $path = trim( (string)parse_url( $reference, PHP_URL_PATH ), '/' );
                // (the siteaccess's path prefix applies, as for a request: translate(), not fetchByPath())
                foreach ( array_unique( array( $path, preg_replace( '#^[^/]+/#', '', $path ) ) ) as $candidate )
                {
                    if ( $candidate === '' )
                        continue;
                    $uri = eZURI::instance( $candidate );
                    $translated = eZURLAliasML::translate( $uri );
                    if ( is_string( $translated ) )
                    {
                        $uri = eZURI::instance( $translated );
                        $translated = eZURLAliasML::translate( $uri );
                    }
                    if ( $translated === true && preg_match( '#^content/view/full/(\d+)$#', (string)$uri->elements(), $m ) )
                    {
                        $node = eZContentObjectTreeNode::fetch( (int)$m[1] );
                        $object = $node instanceof eZContentObjectTreeNode ? $node->object() : null;
                        break;
                    }
                }
            }
        }
        if ( !$object instanceof eZContentObject || $object->attribute( 'class_identifier' ) !== self::CONTRIBUTOR_CLASS )
            return null;
        return $object;
    }

    /**
     * @param eZContentObject|null $into the canonical contributor; null: the relations to $from are removed (a text that
     *                                   is no person, once the pages relate to the real people)
     * @param eZContentObject[] $from the duplicates
     * @return bool whether everything was merged (in a dry run: whether it could be)
     */
    public function merge( $into, array $from )
    {
        $intoID = $into instanceof eZContentObject ? (int)$into->attribute( 'id' ) : 0;
        $this->report['into'] = $into instanceof eZContentObject ? $this->describe( $into ) : null;
        $done = true;
        foreach ( $from as $duplicate )
        {
            $fromID = (int)$duplicate->attribute( 'id' );
            if ( $fromID === $intoID )
            {
                $this->report['errors'][] = "object $fromID is the canonical contributor itself";
                $done = false;
                continue;
            }
            $entry = $this->describe( $duplicate );
            $entry['addresses'] = $this->addresses( $duplicate );
            $this->report['from'][$fromID] = $entry;
            $this->repoint( $fromID, $into );
            if ( $into instanceof eZContentObject )
                $this->mergeProfile( $into, $duplicate );
            $remaining = $this->references( $fromID );
            $this->report['remaining'] += $this->dryRun ? 0 : $remaining;
            $this->report['from'][$fromID]['remaining'] = $this->dryRun ? null : $remaining;
            if ( $this->dryRun )
                continue;
            if ( $remaining )
            {
                $this->report['errors'][] = "object $fromID still has $remaining references; it stays";
                $done = false;
                continue;
            }
            $this->remove( $duplicate, $into, $entry['addresses'] );
        }
        if ( !$this->dryRun )
            $this->clearCaches( $intoID );
        return $done && !$this->report['errors'];
    }

    /**
     * @param eZContentObject $object
     * @return array
     */
    protected function describe( eZContentObject $object )
    {
        $node = $object->mainNode();
        return array( 'object_id' => (int)$object->attribute( 'id' ), 'node_id' => $node ? (int)$node->attribute( 'node_id' ) : 0,
                      'name' => (string)$object->attribute( 'name' ), 'url_alias' => $node ? (string)$node->attribute( 'url_alias' ) : '',
                      'links' => (int)eZDB::instance()->arrayQuery( 'SELECT COUNT(*) AS n FROM ezcontentobject_link WHERE to_contentobject_id = ' . (int)$object->attribute( 'id' ) )[0]['n'] );
    }

    /**
     * @param eZContentObject $object
     * @return array of the addresses of every node of the object (current names and the history), each once
     */
    protected function addresses( eZContentObject $object )
    {
        $paths = array();
        foreach ( $object->assignedNodes() as $node )
            foreach ( (array)eZURLAliasML::fetchByAction( 'eznode', (int)$node->attribute( 'node_id' ), false, false, true ) as $element )
            {
                $path = $element->getPath();
                if ( $path !== '' && $path !== null && !(int)$element->attribute( 'is_alias' ) )
                    $paths[$path] = array( 'path' => $path, 'language' => (int)$element->attribute( 'lang_mask' ) );
            }
        return array_values( $paths );
    }

    /**
     * Every attribute and link row that points at $fromID points at the canonical contributor.
     *
     * @param int $fromID
     * @param eZContentObject $into
     */
    protected function repoint( $fromID, $into )
    {
        $db = eZDB::instance();
        // 0: the relation is removed (an object relation emptied, the item left out of a list)
        $intoID = $into instanceof eZContentObject ? (int)$into->attribute( 'id' ) : 0;
        $rows = $db->arrayQuery( "SELECT a.id, a.version, a.contentobject_id, a.contentclassattribute_id, a.data_type_string, a.language_code
                                  FROM ezcontentobject_attribute a
                                  WHERE ( a.data_type_string = 'ezobjectrelation' AND a.data_int = $fromID )
                                     OR ( a.data_type_string = 'ezobjectrelationlist' AND a.data_text LIKE '%contentobject-id=\"$fromID\"%' )
                                  ORDER BY a.contentobject_id, a.version" );
        foreach ( $rows as $row )
        {
            $label = $this->attributeLabel( (int)$row['contentclassattribute_id'] );
            if ( !isset( $this->report['attributes'][$label] ) )
                $this->report['attributes'][$label] = array( 'attributes' => 0, 'objects' => array(), 'versions' => 0 );
            $this->report['attributes'][$label]['attributes']++;
            $this->report['attributes'][$label]['versions']++;
            $this->report['attributes'][$label]['objects'][(int)$row['contentobject_id']] = true;
            $this->report['objects'][(int)$row['contentobject_id']] = true;
            if ( $this->dryRun )
                continue;
            $attribute = eZContentObjectAttribute::fetch( (int)$row['id'], (int)$row['version'] );
            if ( !$attribute instanceof eZContentObjectAttribute )
                continue;
            if ( $row['data_type_string'] === 'ezobjectrelation' )
            {
                $attribute->setAttribute( 'data_int', $intoID );
                $attribute->setAttribute( 'sort_key_int', $intoID );
                // the datatype writes the link row of this version (removes the old one, adds the new)
                $attribute->store();
                continue;
            }
            $content = $attribute->content();
            $list = array();
            $hasInto = false;
            foreach ( isset( $content['relation_list'] ) ? $content['relation_list'] : array() as $item )
                if ( (int)$item['contentobject_id'] === $intoID )
                    $hasInto = true;
            foreach ( isset( $content['relation_list'] ) ? $content['relation_list'] : array() as $item )
            {
                if ( (int)$item['contentobject_id'] === $fromID )
                {
                    // the canonical contributor in the duplicate's place, once (none when the relation is removed)
                    if ( $hasInto || !$intoID )
                        continue;
                    $hasInto = true;
                    $type = new eZObjectRelationListType();
                    $new = $type->appendObject( $intoID, isset( $item['priority'] ) ? $item['priority'] : 0, $attribute );
                    if ( !$new )
                        continue;
                    unset( $new['object'] );
                    $item = $new;
                }
                $list[] = $item;
            }
            $content['relation_list'] = $list;
            $attribute->setContent( $content );
            $attribute->store();
        }
        // link rows that no attribute holds (an earlier version's, a common relation): moved row by row
        foreach ( $db->arrayQuery( "SELECT from_contentobject_id f, from_contentobject_version v, contentclassattribute_id ca, relation_type t
                                    FROM ezcontentobject_link WHERE to_contentobject_id = $fromID" ) as $link )
        {
            $this->report['links']++;
            $this->report['objects'][(int)$link['f']] = true;
            if ( $this->dryRun )
                continue;
            $object = eZContentObject::fetch( (int)$link['f'] );
            if ( !$object instanceof eZContentObject )
                continue;
            $object->removeContentObjectRelation( $fromID, (int)$link['v'], (int)$link['ca'], (int)$link['t'] );
            $exists = (int)$db->arrayQuery( "SELECT COUNT(*) AS n FROM ezcontentobject_link WHERE from_contentobject_id = " . (int)$link['f']
                                            . " AND from_contentobject_version = " . (int)$link['v'] . " AND to_contentobject_id = $intoID"
                                            . " AND contentclassattribute_id = " . (int)$link['ca'] . " AND relation_type & " . (int)$link['t'] )[0]['n'];
            if ( !$exists && $intoID )
                $object->addContentObjectRelation( $intoID, (int)$link['v'], (int)$link['ca'], (int)$link['t'] );
        }
        foreach ( $this->report['attributes'] as $label => $counts )
            $this->report['attributes'][$label]['objects_count'] = count( $counts['objects'] );
    }

    /**
     * @param int $classAttributeID
     * @return string class/attribute
     */
    protected function attributeLabel( $classAttributeID )
    {
        static $labels = array();
        if ( !isset( $labels[$classAttributeID] ) )
        {
            $classAttribute = eZContentClassAttribute::fetch( $classAttributeID );
            $class = $classAttribute ? eZContentClass::fetch( (int)$classAttribute->attribute( 'contentclass_id' ) ) : null;
            $labels[$classAttributeID] = ( $class ? $class->attribute( 'identifier' ) : '?' ) . '/' . ( $classAttribute ? $classAttribute->attribute( 'identifier' ) : $classAttributeID );
        }
        return $labels[$classAttributeID];
    }

    /**
     * @param int $fromID
     * @return int the attributes (any version) and link rows that still point at the object
     */
    public function references( $fromID )
    {
        $db = eZDB::instance();
        $fromID = (int)$fromID;
        $attributes = (int)$db->arrayQuery( "SELECT COUNT(*) AS n FROM ezcontentobject_attribute a
                                             WHERE ( a.data_type_string = 'ezobjectrelation' AND a.data_int = $fromID )
                                                OR ( a.data_type_string = 'ezobjectrelationlist' AND a.data_text LIKE '%contentobject-id=\"$fromID\"%' )" )[0]['n'];
        $links = (int)$db->arrayQuery( "SELECT COUNT(*) AS n FROM ezcontentobject_link WHERE to_contentobject_id = $fromID" )[0]['n'];
        return $attributes + $links;
    }

    /**
     * The canonical contributor takes the duplicate's profile values where its own are empty (never its name).
     *
     * @param eZContentObject $into
     * @param eZContentObject $from
     */
    protected function mergeProfile( eZContentObject $into, eZContentObject $from )
    {
        $intoMap = $into->dataMap();
        $values = array();
        foreach ( $from->dataMap() as $identifier => $attribute )
        {
            if ( $identifier === 'name' || !isset( $intoMap[$identifier] ) || in_array( $attribute->attribute( 'data_type_string' ), array( 'xrowmetadata' ), true ) )
                continue;
            if ( $attribute->hasContent() && !$intoMap[$identifier]->hasContent() && (string)$attribute->toString() !== '' )
                $values[$identifier] = (string)$attribute->toString();
        }
        if ( !$values )
            return;
        $this->report['profile'][(int)$from->attribute( 'id' )] = array_keys( $values );
        if ( $this->dryRun )
            return;
        // an image is given as its file
        if ( isset( $values['image'] ) && isset( $from->dataMap()['image'] ) && $from->dataMap()['image']->attribute( 'data_type_string' ) === 'ezimage' )
        {
            $parts = explode( '|', $values['image'] );
            if ( $parts[0] !== '' && !is_file( $parts[0] ) )
                unset( $values['image'] );
        }
        if ( $values && !eZContentFunctions::updateAndPublishObject( $into, array( 'attributes' => $values ) ) )
            $this->report['errors'][] = 'the profile of object ' . (int)$from->attribute( 'id' ) . ' could not be copied: ' . implode( ', ', array_keys( $values ) );
        eZContentObject::clearCache( array( (int)$into->attribute( 'id' ) ) );
    }

    /**
     * The duplicate goes to the trash (and out of it with $purge); its addresses redirect to the canonical contributor.
     *
     * @param eZContentObject $duplicate
     * @param eZContentObject $into
     * @param array $addresses
     */
    protected function remove( eZContentObject $duplicate, $into, array $addresses )
    {
        $fromID = (int)$duplicate->attribute( 'id' );
        $nodeIDs = array();
        foreach ( $duplicate->assignedNodes() as $node )
            $nodeIDs[] = (int)$node->attribute( 'node_id' );
        $parents = array();
        foreach ( $duplicate->assignedNodes() as $node )
            $parents[] = (int)$node->attribute( 'parent_node_id' );
        if ( $nodeIDs )
            eZContentObjectTreeNode::removeSubtrees( $nodeIDs, true );
        $this->report['trashed'][] = $fromID;
        if ( $this->purge )
        {
            eZContentObject::clearCache( array( $fromID ) );
            $object = eZContentObject::fetch( $fromID );
            if ( $object instanceof eZContentObject && (int)$object->attribute( 'status' ) === eZContentObject::STATUS_ARCHIVED )
            {
                $object->purge();
                $this->report['purged'][] = $fromID;
            }
            else
                $this->report['errors'][] = "object $fromID is not in the trash, so it was not purged";
        }
        // the old addresses: custom aliases of the canonical contributor that redirect there (a removed text that was no
        // person has none: its address is gone, 404)
        if ( !$into instanceof eZContentObject )
        {
            foreach ( array_unique( $parents ) as $parentNodeID )
                if ( $parent = eZContentObjectTreeNode::fetch( $parentNodeID ) )
                    eZContentCacheManager::clearObjectViewCacheIfNeeded( (int)$parent->attribute( 'contentobject_id' ) );
            return;
        }
        $intoNode = $into->mainNode();
        $name = null;
        foreach ( (array)eZURLAliasML::fetchByAction( 'eznode', (int)$intoNode->attribute( 'node_id' ) ) as $element )
            if ( (int)$element->attribute( 'is_original' ) && !(int)$element->attribute( 'is_alias' ) )
                $name = $element;
        $language = eZContentLanguage::topPriorityLanguage();
        foreach ( $addresses as $address )
        {
            $result = eZURLAliasML::storePath( $address['path'], 'eznode:' . (int)$intoNode->attribute( 'node_id' ), $language,
                                               $name ? (int)$name->attribute( 'id' ) : false, true, 0, true, false, false, true );
            $ok = is_array( $result ) && !empty( $result['status'] ) && $result['status'] === true;
            $this->report['redirects'][] = array( 'path' => $address['path'], 'to' => (string)$intoNode->attribute( 'url_alias' ), 'ok' => $ok,
                                                  'status' => is_array( $result ) ? $result['status'] : $result );
            if ( !$ok )
                $this->report['errors'][] = "the address {$address['path']} could not be made a redirect";
        }
        foreach ( array_unique( $parents ) as $parentNodeID )
            if ( $parent = eZContentObjectTreeNode::fetch( $parentNodeID ) )
                eZContentCacheManager::clearObjectViewCacheIfNeeded( (int)$parent->attribute( 'contentobject_id' ) );
    }

    /**
     * The view caches of the objects that changed and of the canonical contributor (its page lists them).
     *
     * @param int $intoID
     */
    protected function clearCaches( $intoID )
    {
        $ids = array_map( 'intval', array_keys( $this->report['objects'] ) );
        $ids[] = (int)$intoID;
        eZContentObject::clearCache();
        foreach ( array_chunk( array_unique( $ids ), 50 ) as $chunk )
            eZContentCacheManager::clearObjectViewCacheIfNeeded( $chunk );
    }
}
