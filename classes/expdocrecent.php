<?php
/**
 * The recent changes of the documentation (the view doc/recent, its feed and the front page's list): every page of
 * the site's tree, newest change first, with the filters of exp_doc.ini [RecentSettings].
 *
 * A filter set is a hash of view parameters, every key optional:
 *   manual       the node id of a manual (exp_doc_manual): only its pages
 *   version      the node id of a manual version (exp_doc_version): only its pages
 *   class        a class identifier of [RecentSettings] Classes[]
 *   contributor  the object id of a contributor: the pages they last updated (last_updated_by)
 *   range        24h, 7d, 30d or all (default): changed within that time
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocRecent
{
    /** the time ranges and their length in seconds (0: all) */
    public static $ranges = array( '24h' => 86400, '7d' => 604800, '30d' => 2592000, 'all' => 0 );

    /**
     * The filters of a request, checked: unknown keys and values that are not valid are dropped.
     *
     * @param array $params the view's unordered parameters (key => value)
     * @return array key => value, only the filters that apply
     */
    public static function filters( array $params )
    {
        $filters = array();
        foreach ( array( 'manual', 'version', 'contributor' ) as $key )
        {
            if ( isset( $params[$key] ) && ctype_digit( (string)$params[$key] ) && (int)$params[$key] > 0 )
            {
                $filters[$key] = (int)$params[$key];
            }
        }
        if ( isset( $params['class'] ) && in_array( $params['class'], self::classes(), true ) )
        {
            $filters['class'] = $params['class'];
        }
        if ( isset( $params['range'] ) && isset( self::$ranges[$params['range']] ) && $params['range'] !== 'all' )
        {
            $filters['range'] = $params['range'];
        }
        return $filters;
    }

    /**
     * The address of the view with these filters, as view parameters (never a query string), from the module's
     * alias ([RecentSettings] Path) on: "recent/(manual)/12/(range)/7d".
     *
     * @param array $filters
     * @param array $extra more view parameters (offset, limit, feed)
     * @return string
     */
    public static function uri( array $filters, array $extra = array() )
    {
        $uri = (string)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', 'Path' );
        foreach ( array_merge( $filters, $extra ) as $key => $value )
        {
            if ( $value !== '' && $value !== null && $value !== false )
            {
                $uri .= '/(' . $key . ')/' . rawurlencode( (string)$value );
            }
        }
        return $uri;
    }

    /** @return string[] the classes the list takes */
    public static function classes()
    {
        return array_values( (array)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', 'Classes' ) );
    }

    /**
     * One page of the list and the count of all entries that match.
     *
     * @param array $filters see filters()
     * @param int $offset
     * @param int $limit
     * @return array array( 'items' => list of entry hashes (see entry()), 'count' => int )
     */
    public static function fetch( array $filters, $offset, $limit )
    {
        $parentID = (int)eZINI::instance( 'content.ini' )->variable( 'NodeSettings', 'RootNode' );
        if ( isset( $filters['version'] ) )
        {
            $parentID = $filters['version'];
        }
        elseif ( isset( $filters['manual'] ) )
        {
            $parentID = $filters['manual'];
        }
        $classes = isset( $filters['class'] ) ? array( $filters['class'] ) : self::classes();
        $params = array( 'ClassFilterType' => 'include', 'ClassFilterArray' => $classes, 'MainNodeOnly' => true,
                         'SortBy' => array( 'modified', false ) );
        $attributeFilter = array();
        if ( isset( $filters['range'] ) )
        {
            $attributeFilter[] = array( 'modified', '>=', time() - self::$ranges[$filters['range']] );
        }
        if ( isset( $filters['contributor'] ) )
        {
            // last_updated_by on every class that has it, one condition per class
            $byClass = array( 'or' );
            foreach ( $classes as $class )
            {
                if ( eZContentClassAttribute::classAttributeIDByIdentifier( $class . '/last_updated_by' ) )
                {
                    $byClass[] = array( $class . '/last_updated_by', '=', $filters['contributor'] );
                }
            }
            if ( count( $byClass ) === 1 )
            {
                return array( 'items' => array(), 'count' => 0 );
            }
            $attributeFilter[] = count( $byClass ) === 2 ? $byClass[1] : $byClass;
        }
        if ( $attributeFilter )
        {
            $params['AttributeFilter'] = count( $attributeFilter ) === 1 ? $attributeFilter : array_merge( array( 'and' ), $attributeFilter );
        }
        $count = (int)eZContentObjectTreeNode::subTreeCountByNodeID( $params, $parentID );
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array_merge( $params, array( 'Offset' => (int)$offset, 'Limit' => (int)$limit ) ), $parentID );
        $items = array();
        foreach ( is_array( $nodes ) ? $nodes : array() as $node )
        {
            $items[] = self::entry( $node );
        }
        return array( 'items' => $items, 'count' => $count );
    }

    /**
     * One entry of the list: node, title, url (the node's address), day (Y-m-d of the change, for the grouping),
     * modified, type (new, updated or history: a historical copy, moved to the page's history), manual and version
     * (their nodes or false), by (the contributor object who last updated it, or false), updated_at (last_updated_at,
     * else 0), excerpt (the start of the body as plain text).
     *
     * @param eZContentObjectTreeNode $node
     * @return array
     */
    public static function entry( eZContentObjectTreeNode $node )
    {
        $object = $node->object();
        $map = $node->dataMap();
        $historyClasses = (array)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', 'HistoryClasses' );
        $modified = (int)$object->attribute( 'modified' );
        if ( in_array( $node->attribute( 'class_identifier' ), $historyClasses, true )
             || ( isset( $map['history_of'] ) && $map['history_of']->hasContent() ) )
        {
            $type = 'history';
        }
        elseif ( (int)$object->attribute( 'current_version' ) === 1 )
        {
            $type = 'new';
        }
        else
        {
            $type = 'updated';
        }
        $manual = false;
        $version = false;
        foreach ( array_reverse( $node->fetchPath() ) as $ancestor )
        {
            $class = $ancestor->attribute( 'class_identifier' );
            if ( !$version && $class === 'exp_doc_version' ) { $version = $ancestor; }
            if ( !$manual && $class === 'exp_doc_manual' ) { $manual = $ancestor; }
        }
        $by = false;
        if ( isset( $map['last_updated_by'] ) && $map['last_updated_by']->hasContent() )
        {
            $by = eZContentObject::fetch( (int)$map['last_updated_by']->attribute( 'data_int' ) );
        }
        $updatedAt = isset( $map['last_updated_at'] ) && $map['last_updated_at']->hasContent() ? (int)$map['last_updated_at']->attribute( 'data_int' ) : 0;
        $excerpt = '';
        if ( isset( $map['body'] ) && $map['body']->hasContent() )
        {
            // the XML stores entities once more escaped (&amp;middot;), so they are decoded twice
            $text = trim( preg_replace( '/\s+/u', ' ', html_entity_decode( html_entity_decode( strip_tags( str_replace( '<', ' <', $map['body']->attribute( 'data_text' ) ) ), ENT_QUOTES, 'UTF-8' ), ENT_QUOTES, 'UTF-8' ) ) );
            $length = (int)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', 'ExcerptLength' );
            $excerpt = mb_strlen( $text ) > $length ? rtrim( mb_substr( $text, 0, $length ) ) . '…' : $text;
        }
        return array( 'node' => $node, 'title' => $node->attribute( 'name' ), 'url' => $node->attribute( 'url_alias' ),
                      'day' => date( 'Y-m-d', $modified ), 'modified' => $modified, 'type' => $type,
                      'manual' => $manual, 'version' => $version, 'by' => $by instanceof eZContentObject ? $by : false,
                      'updated_at' => $updatedAt, 'excerpt' => $excerpt );
    }

    /**
     * The entries grouped by the day of their change, in their order: list of array( 'day' => timestamp of that
     * day's start, 'items' => entries ).
     *
     * @param array $items
     * @return array
     */
    public static function byDay( array $items )
    {
        $groups = array();
        foreach ( $items as $item )
        {
            if ( !$groups || $groups[count( $groups ) - 1]['key'] !== $item['day'] )
            {
                $groups[] = array( 'key' => $item['day'], 'day' => strtotime( $item['day'] ), 'items' => array() );
            }
            $groups[count( $groups ) - 1]['items'][] = $item;
        }
        return $groups;
    }

    /**
     * The choices of the filter form: manuals and versions (nodes), classes (identifier => name) and contributors
     * (objects, by name).
     *
     * @return array
     */
    public static function options()
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $rootID = (int)eZINI::instance( 'content.ini' )->variable( 'NodeSettings', 'RootNode' );
        $manuals = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( 'exp_doc_manual' ),
                                                                   'SortBy' => array( 'priority', true ), 'Limit' => 50 ), $rootID );
        $versions = array();
        foreach ( is_array( $manuals ) ? $manuals : array() as $manual )
        {
            $list = expDocFetch::versions( $manual->attribute( 'node_id' ) );
            foreach ( $list['result'] as $version )
            {
                $versions[] = array( 'node' => $version, 'manual' => $manual );
            }
        }
        $classes = array();
        foreach ( self::classes() as $identifier )
        {
            $class = eZContentClass::fetchByIdentifier( $identifier );
            if ( $class )
            {
                $classes[$identifier] = $class->attribute( 'name' );
            }
        }
        $contributors = array();
        $folder = eZContentObject::fetchByRemoteID( (string)$ini->variable( 'RecentSettings', 'ContributorFolderRemoteID' ) );
        if ( $folder && $folder->mainNode() )
        {
            $list = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( 'exp_doc_contributor' ),
                                                                     'SortBy' => array( 'name', true ),
                                                                     'Limit' => (int)$ini->variable( 'RecentSettings', 'ContributorLimit' ) ),
                                                              $folder->mainNode()->attribute( 'node_id' ) );
            foreach ( is_array( $list ) ? $list : array() as $contributor )
            {
                $contributors[] = $contributor->object();
            }
        }
        return array( 'manuals' => is_array( $manuals ) ? $manuals : array(), 'versions' => $versions,
                      'classes' => $classes, 'contributors' => $contributors, 'ranges' => array_keys( self::$ranges ) );
    }

    /**
     * The Atom feed of the entries.
     *
     * @param array $items entries (see entry())
     * @param string $title
     * @param string $selfUri the feed's own address (absolute)
     * @param string $pageUri the list's address (absolute)
     * @return string
     */
    public static function atom( array $items, $title, $selfUri, $pageUri )
    {
        $base = 'https://' . eZSys::hostname();
        $esc = function ( $text ) { return htmlspecialchars( (string)$text, ENT_XML1 | ENT_QUOTES, 'UTF-8' ); };
        $updated = $items ? $items[0]['modified'] : time();
        $xml = '<?xml version="1.0" encoding="utf-8"?>' . "\n"
             . '<feed xmlns="http://www.w3.org/2005/Atom">' . "\n"
             . '  <title>' . $esc( $title ) . "</title>\n"
             . '  <id>' . $esc( $selfUri ) . "</id>\n"
             . '  <link rel="self" type="application/atom+xml" href="' . $esc( $selfUri ) . '"/>' . "\n"
             . '  <link rel="alternate" type="text/html" href="' . $esc( $pageUri ) . '"/>' . "\n"
             . '  <updated>' . date( DATE_ATOM, $updated ) . "</updated>\n"
             . '  <author><name>' . $esc( $title ) . "</name></author>\n";
        foreach ( $items as $item )
        {
            $url = $item['url'];
            eZURI::transformURI( $url );
            $url = $base . $url;
            $context = array();
            if ( $item['manual'] ) { $context[] = $item['manual']->attribute( 'name' ); }
            if ( $item['version'] ) { $context[] = $item['version']->attribute( 'name' ); }
            $xml .= "  <entry>\n"
                  . '    <title>' . $esc( $item['title'] ) . "</title>\n"
                  . '    <id>' . $esc( $url ) . '#' . $item['modified'] . "</id>\n"
                  . '    <link rel="alternate" type="text/html" href="' . $esc( $url ) . '"/>' . "\n"
                  . '    <updated>' . date( DATE_ATOM, $item['modified'] ) . "</updated>\n"
                  . ( $item['by'] ? '    <author><name>' . $esc( $item['by']->attribute( 'name' ) ) . "</name></author>\n" : '' )
                  . '    <category term="' . $esc( $item['type'] ) . '"/>' . "\n"
                  . '    <summary>' . $esc( ( $context ? implode( ' · ', $context ) . ': ' : '' ) . $item['excerpt'] ) . "</summary>\n"
                  . "  </entry>\n";
        }
        return $xml . "</feed>\n";
    }
}
