<?php
/**
 * The template fetch functions of exp_doc (modules/exp_doc/function_definition.php).
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocFetch
{
    /** @var array path => node id (0: none), for the request */
    protected static $cache = array();

    /**
     * The node imported from a static file: the main node of the object whose source_path attribute equals $path
     * (relative to the static repository's root, without a leading slash). Only the published version counts.
     *
     * @param string $path
     * @return array array( 'result' => eZContentObjectTreeNode|false )
     */
    public static function nodeBySource( $path )
    {
        $path = ltrim( trim( (string)$path ), '/' );
        if ( $path === '' )
        {
            return array( 'result' => false );
        }
        if ( !array_key_exists( $path, self::$cache ) )
        {
            self::$cache[$path] = self::lookup( $path );
        }
        $nodeID = self::$cache[$path];
        if ( !$nodeID )
        {
            return array( 'result' => false );
        }
        $node = eZContentObjectTreeNode::fetch( $nodeID );
        return array( 'result' => ( $node instanceof eZContentObjectTreeNode && $node->canRead() ) ? $node : false );
    }

    /**
     * Everyone a page names, for its "Contributors" list: the objects of its contributors relation list, in that order,
     * each with the roles the page gives them: author (written_by, with written_at), updated (last_updated_by, with
     * last_updated_at), maintainer (maintainers) and commenter (a comment below the page, exp_doc.ini [ClassicSettings]
     * CommentClass, whose author is that name, with the first comment's date).
     *
     * @param int $nodeID
     * @return array array( 'result' => list of array( 'object', 'node', 'name', 'roles', 'dates' ) )
     */
    public static function contributors( $nodeID )
    {
        $node = eZContentObjectTreeNode::fetch( (int)$nodeID );
        if ( !$node instanceof eZContentObjectTreeNode )
        {
            return array( 'result' => array() );
        }
        $map = $node->dataMap();
        $ids = isset( $map['contributors'] ) ? self::relationIDs( $map['contributors'] ) : array();
        $single = function ( $identifier ) use ( $map )
        {
            return isset( $map[$identifier] ) && $map[$identifier]->hasContent() ? (int)$map[$identifier]->attribute( 'data_int' ) : 0;
        };
        $date = function ( $identifier ) use ( $map )
        {
            return isset( $map[$identifier] ) && $map[$identifier]->hasContent() ? (int)$map[$identifier]->attribute( 'data_int' ) : 0;
        };
        $author = $single( 'written_by' );
        $updater = $single( 'last_updated_by' );
        $maintainers = isset( $map['maintainers'] ) ? self::relationIDs( $map['maintainers'] ) : array();
        // comment authors, by name (comments carry the author as text)
        $commented = array();
        $commentClass = eZINI::instance( 'exp_doc.ini' )->variable( 'ClassicSettings', 'CommentClass' );
        $comments = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( $commentClass ),
                                                                    'SortBy' => array( 'published', true ) ), $node->attribute( 'node_id' ) );
        foreach ( is_array( $comments ) ? $comments : array() as $comment )
        {
            $cmap = $comment->dataMap();
            $name = isset( $cmap['author'] ) ? mb_strtolower( trim( $cmap['author']->toString() ) ) : '';
            if ( $name !== '' && !isset( $commented[$name] ) )
            {
                $commented[$name] = isset( $cmap['created'] ) && $cmap['created']->hasContent() ? (int)$cmap['created']->attribute( 'data_int' ) : (int)$comment->object()->attribute( 'published' );
            }
        }
        $result = array();
        foreach ( $ids as $id )
        {
            $object = eZContentObject::fetch( $id );
            if ( !$object instanceof eZContentObject )
            {
                continue;
            }
            $roles = array();
            $dates = array();
            if ( $id === $author ) { $roles[] = 'author'; $dates['author'] = $date( 'written_at' ); }
            if ( $id === $updater ) { $roles[] = 'updated'; $dates['updated'] = $date( 'last_updated_at' ); }
            if ( in_array( $id, $maintainers, true ) ) { $roles[] = 'maintainer'; }
            $key = mb_strtolower( trim( $object->attribute( 'name' ) ) );
            if ( isset( $commented[$key] ) ) { $roles[] = 'commenter'; $dates['commenter'] = $commented[$key]; }
            $result[] = array( 'object' => $object, 'node' => $object->mainNode(), 'name' => $object->attribute( 'name' ),
                               'roles' => $roles, 'dates' => $dates );
        }
        return array( 'result' => $result );
    }

    /**
     * Every contributor of the site, for the Contributors folder's page: the exp_doc_contributor objects below the
     * folder (exp_doc.ini [RecentSettings] ContributorFolderRemoteID), each with the number of pages that name them
     * as writer (written_by), last updater (last_updated_by) and maintainer (maintainers), the current versions of
     * published pages only; sorted by the sum of the three, then by name.
     *
     * @return array array( 'result' => list of array( 'object', 'node', 'name', 'written', 'updated', 'maintained',
     *               'total', 'roles' (author, updated, maintainer: the roles with at least one page) ) )
     */
    public static function contributorList()
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $folder = eZContentObject::fetchByRemoteID( (string)$ini->variable( 'RecentSettings', 'ContributorFolderRemoteID' ) );
        if ( !$folder || !$folder->mainNode() )
        {
            return array( 'result' => array() );
        }
        $db = eZDB::instance();
        $attributeIDs = function ( $identifier ) use ( $db )
        {
            $rows = $db->arrayQuery( "SELECT id FROM ezcontentclass_attribute WHERE version = 0 AND identifier = '" . $db->escapeString( $identifier ) . "'" );
            $ids = array_map( 'intval', array_column( $rows, 'id' ) );
            return $ids ? implode( ',', $ids ) : '0';
        };
        $counts = array( 'written' => array(), 'updated' => array(), 'maintained' => array() );
        // one aggregate per role: the single relations from the attribute data, the relation list from the links
        foreach ( array( 'written' => 'written_by', 'updated' => 'last_updated_by' ) as $key => $identifier )
        {
            foreach ( $db->arrayQuery( "SELECT ca.data_int AS id, COUNT(*) AS n FROM ezcontentobject_attribute ca, ezcontentobject o
                                        WHERE ca.contentclassattribute_id IN ( " . $attributeIDs( $identifier ) . " ) AND ca.data_int > 0
                                        AND o.id = ca.contentobject_id AND o.current_version = ca.version AND o.status = 1
                                        GROUP BY ca.data_int" ) as $row )
            {
                $counts[$key][(int)$row['id']] = (int)$row['n'];
            }
        }
        foreach ( $db->arrayQuery( "SELECT l.to_contentobject_id AS id, COUNT( DISTINCT l.from_contentobject_id ) AS n
                                    FROM ezcontentobject_link l, ezcontentobject o
                                    WHERE l.contentclassattribute_id IN ( " . $attributeIDs( 'maintainers' ) . " )
                                    AND o.id = l.from_contentobject_id AND o.current_version = l.from_contentobject_version AND o.status = 1
                                    GROUP BY l.to_contentobject_id" ) as $row )
        {
            $counts['maintained'][(int)$row['id']] = (int)$row['n'];
        }
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( 'exp_doc_contributor' ),
                                                                 'Depth' => 1, 'DepthOperator' => 'eq' ),
                                                          $folder->mainNode()->attribute( 'node_id' ) );
        $result = array();
        foreach ( is_array( $nodes ) ? $nodes : array() as $node )
        {
            $id = (int)$node->attribute( 'contentobject_id' );
            $entry = array( 'object' => $node->object(), 'node' => $node, 'name' => $node->attribute( 'name' ) );
            $roles = array();
            foreach ( array( 'written' => 'author', 'updated' => 'updated', 'maintained' => 'maintainer' ) as $key => $role )
            {
                $entry[$key] = isset( $counts[$key][$id] ) ? $counts[$key][$id] : 0;
                if ( $entry[$key] ) { $roles[] = $role; }
            }
            $entry['total'] = $entry['written'] + $entry['updated'] + $entry['maintained'];
            $entry['roles'] = $roles;
            $result[] = $entry;
        }
        usort( $result, function ( $a, $b )
        {
            return $b['total'] <=> $a['total'] ?: strcasecmp( $a['name'], $b['name'] );
        } );
        return array( 'result' => $result );
    }

    /**
     * The object ids of a relation list attribute, in its order.
     *
     * @param eZContentObjectAttribute $attribute
     * @return int[]
     */
    protected static function relationIDs( eZContentObjectAttribute $attribute )
    {
        $ids = array();
        $content = $attribute->content();
        foreach ( isset( $content['relation_list'] ) ? $content['relation_list'] : array() as $item )
        {
            $ids[] = (int)$item['contentobject_id'];
        }
        return $ids;
    }

    /**
     * The children of a node as the documentation's menus list them: in the parent's sort order, without the classes
     * of exp_doc.ini [ClassicSettings] MenuHideClasses[] and the nodes named by remote id in MenuHideNodeRemoteIDs[].
     * Only nodes the reader may see.
     *
     * @param int $parentNodeID
     * @param int|false $limit at most this many (false: all)
     * @return array array( 'result' => eZContentObjectTreeNode[] )
     */
    public static function menuChildren( $parentNodeID, $limit = false )
    {
        $parent = eZContentObjectTreeNode::fetch( (int)$parentNodeID );
        if ( !$parent instanceof eZContentObjectTreeNode )
        {
            return array( 'result' => array() );
        }
        $ini = eZINI::instance( 'exp_doc.ini' );
        $hideClasses = $ini->hasVariable( 'ClassicSettings', 'MenuHideClasses' ) ? (array)$ini->variable( 'ClassicSettings', 'MenuHideClasses' ) : array();
        $hideNodes = $ini->hasVariable( 'ClassicSettings', 'MenuHideNodeRemoteIDs' ) ? (array)$ini->variable( 'ClassicSettings', 'MenuHideNodeRemoteIDs' ) : array();
        $params = array( 'Depth' => 1, 'DepthOperator' => 'eq', 'SortBy' => $parent->sortArray() );
        if ( $limit && (int)$limit > 0 )
        {
            // a few more than asked: the hidden remote ids are left out after the fetch
            $params['Limit'] = (int)$limit + count( $hideNodes );
        }
        if ( $hideClasses )
        {
            $params['ClassFilterType'] = 'exclude';
            $params['ClassFilterArray'] = array_values( $hideClasses );
        }
        $children = eZContentObjectTreeNode::subTreeByNodeID( $params, $parent->attribute( 'node_id' ) );
        $result = array();
        foreach ( is_array( $children ) ? $children : array() as $child )
        {
            if ( !in_array( $child->attribute( 'remote_id' ), $hideNodes, true ) )
            {
                $result[] = $child;
            }
        }
        if ( $limit && (int)$limit > 0 )
        {
            $result = array_slice( $result, 0, (int)$limit );
        }
        return array( 'result' => $result );
    }

    /**
     * The version nodes (exp_doc_version) below a manual, newest first by their version number: the attribute
     * version, else the node's name; "x" (6.x) counts as the highest number of its line, and anything that is not a
     * number sorts last. Only nodes the reader may see.
     *
     * @param int $parentNodeID
     * @return array array( 'result' => eZContentObjectTreeNode[] )
     */
    public static function versions( $parentNodeID )
    {
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array( 'Depth' => 1, 'DepthOperator' => 'eq',
                                                                 'ClassFilterType' => 'include',
                                                                 'ClassFilterArray' => array( 'exp_doc_version' ) ), (int)$parentNodeID );
        $nodes = is_array( $nodes ) ? $nodes : array();
        $keys = array();
        foreach ( $nodes as $i => $node )
        {
            $keys[$i] = self::versionKey( $node );
        }
        uksort( $nodes, function ( $a, $b ) use ( $keys )
        {
            if ( $keys[$a] === null || $keys[$b] === null )
                return ( $keys[$a] === null ) - ( $keys[$b] === null );
            return version_compare( $keys[$b], $keys[$a] );
        } );
        return array( 'result' => array_values( $nodes ) );
    }

    /**
     * The comparable version of a version node ("6.x" becomes "6.99999"), or null when it has none.
     *
     * @param eZContentObjectTreeNode $node
     * @return string|null
     */
    public static function versionKey( eZContentObjectTreeNode $node )
    {
        $map = $node->dataMap();
        foreach ( array( isset( $map['version'] ) ? $map['version']->toString() : '', (string)$node->attribute( 'name' ) ) as $text )
        {
            $text = trim( strtolower( $text ) );
            if ( preg_match( '/^\d+(\.(\d+|x))*$/', $text ) )
            {
                return str_replace( 'x', '99999', $text );
            }
        }
        return null;
    }

    /**
     * The main node id of the page imported from $path: by the import's remote id (staticimport-<type>-<md5 of the
     * path>), else by the published object whose source_path is $path; 0 when none.
     *
     * @param string $path
     * @return int
     */
    protected static function lookup( $path )
    {
        // the import's own remote id first (staticimport-doc-html-<md5 of the source path>), then the source_path attribute
        foreach ( array( 'doc-html', 'html-generic', 'markdown', 'sitemap-crawl' ) as $type )
        {
            $object = eZContentObject::fetchByRemoteID( 'staticimport-' . $type . '-' . md5( $path ) );
            if ( $object instanceof eZContentObject && $object->attribute( 'main_node_id' ) )
            {
                return (int)$object->attribute( 'main_node_id' );
            }
        }
        $classAttributeIDs = array();
        foreach ( eZContentClassAttribute::fetchFilteredList( array( 'identifier' => 'source_path', 'version' => eZContentClass::VERSION_STATUS_DEFINED ) ) as $classAttribute )
        {
            $classAttributeIDs[] = (int)$classAttribute->attribute( 'id' );
        }
        if ( !$classAttributeIDs )
        {
            return 0;
        }
        $attributes = eZPersistentObject::fetchObjectList( eZContentObjectAttribute::definition(), null,
                                                           array( 'contentclassattribute_id' => array( $classAttributeIDs ),
                                                                  'data_text' => $path ),
                                                           null, null, true );
        foreach ( (array)$attributes as $attribute )
        {
            $object = eZContentObject::fetch( $attribute->attribute( 'contentobject_id' ) );
            if ( $object instanceof eZContentObject
                 && (int)$object->attribute( 'current_version' ) === (int)$attribute->attribute( 'version' )
                 && $object->attribute( 'main_node_id' ) )
            {
                return (int)$object->attribute( 'main_node_id' );
            }
        }
        return 0;
    }
}
