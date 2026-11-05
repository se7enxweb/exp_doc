<?php
/**
 * The recent changes of the documentation (the view doc/recent, its feed and the front page's list): every page of
 * the site's tree, newest change first, with the filters of exp_doc.ini [RecentSettings].
 *
 * A filter set is a hash of view parameters, every key optional:
 *   manual       the node id of a manual (exp_doc_manual): only its pages; or help: only the Markdown pages of the help
 *                center (the kernel's help index, expHelpDocumentIndex, in the reader's help language)
 *   version      the node id of a manual version (exp_doc_version): only its pages
 *   class        a class identifier of [RecentSettings] Classes[]; markdown (the kind "Markdown page") is manual help
 *   contributor  the object id of a contributor: the pages they last updated (last_updated_by)
 *   range        24h, 7d, 30d or all (default): changed within that time
 *
 * Without manual, version, class and contributor the recent changes (mode changed) take the help's Markdown pages too,
 * merged with the content pages by date. Version, class and contributor do not apply to Markdown pages, so with
 * manual help they are dropped. The pages added (mode new) stay content pages only: the help index knows when a
 * Markdown file last changed (its last commit), not when it was added.
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
     * The Markdown pages (manual help, class markdown) only when asked for (the recent changes; not the pages added,
     * the comments or the ratings) and when the help is on; class markdown becomes manual help, and with manual help version, class and contributor are dropped.
     *
     * @param array $params the view's unordered parameters (key => value)
     * @param bool $withHelp whether the Markdown pages are a choice
     * @return array key => value, only the filters that apply
     */
    public static function filters( array $params, $withHelp = false )
    {
        $filters = array();
        $help = $withHelp && self::helpAvailable();
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
        if ( $help && ( ( isset( $params['manual'] ) && $params['manual'] === self::HELP )
                        || ( isset( $params['class'] ) && $params['class'] === self::HELP_KIND ) ) )
        {
            $filters = array( 'manual' => self::HELP );
        }
        if ( isset( $params['range'] ) && isset( self::$ranges[$params['range']] ) && $params['range'] !== 'all' )
        {
            $filters['range'] = $params['range'];
        }
        return $filters;
    }

    /** the manual filter's value of the help center's Markdown pages */
    const HELP = 'help';

    /** the kind of page (class filter) of the help center's Markdown pages */
    const HELP_KIND = 'markdown';

    /** @var array|null the help's visible pages by date, newest first, per range (helpPages()) */
    protected static $helpPages = array();

    /**
     * Whether the help center's Markdown pages can be listed: the help is on and the kernel has the help index.
     *
     * @return bool
     */
    public static function helpAvailable()
    {
        return class_exists( 'expHelp' ) && expHelp::isEnabled() && class_exists( 'expHelpDocumentIndex' )
               && method_exists( 'expHelpDocumentIndex', 'visibleDocuments' );
    }

    /**
     * The help's visible Markdown pages (expHelpDocumentIndex::visibleDocuments(): the pages of the reader's help
     * language, from the index's cache) by the date of their last change, newest first: the date of the file's last
     * commit the index read ('changed'), else the file's modification time. Ties by id, so the paging is stable.
     *
     * @param int $since only the pages changed at or after this time (0: all)
     * @return array list of array( 'id', 'time' )
     */
    public static function helpPages( $since = 0 )
    {
        $since = (int)$since;
        if ( !isset( self::$helpPages[$since] ) )
        {
            $ids = array();
            $times = array();
            foreach ( expHelpDocumentIndex::instance()->visibleDocuments() as $id => $document )
            {
                $time = isset( $document['changed'] ) ? (int)$document['changed'] : ( isset( $document['mtime'] ) ? (int)$document['mtime'] : 0 );
                if ( $time >= $since )
                {
                    $ids[] = (string)$id;
                    $times[] = $time;
                }
            }
            array_multisort( $times, SORT_DESC, SORT_NUMERIC, $ids, SORT_ASC, SORT_STRING );
            $pages = array();
            foreach ( $ids as $i => $id )
            {
                $pages[] = array( 'id' => $id, 'time' => $times[$i] );
            }
            self::$helpPages[$since] = $pages;
        }
        return self::$helpPages[$since];
    }

    /**
     * One entry of a help Markdown page, with the keys of entry() (node, manual, version, by and author false; the
     * type updated: the index knows the last change, not the first) and help (true), section (the name of the
     * help's category the page belongs to) and section_url (the help's list of that category, or false).
     *
     * @param array $page array( 'id', 'time' ) of helpPages()
     * @return array|null null when the index no longer has the page
     */
    public static function helpEntry( array $page )
    {
        $index = expHelpDocumentIndex::instance();
        $document = $index->document( $page['id'] );
        if ( $document === null )
        {
            return null;
        }
        static $categories = null;
        if ( $categories === null )
        {
            $categories = method_exists( $index, 'categories' ) ? $index->categories() : array();
        }
        $category = isset( $document['category'] ) ? (string)$document['category'] : '';
        $section = isset( $categories[$category]['name'] ) ? (string)$categories[$category]['name'] : '';
        $sectionUrl = false;
        if ( $section !== '' && method_exists( 'expHelp', 'searchUrl' ) )
        {
            $sectionUrl = expHelp::searchUrl( array( 'category' => $category ) );
            if ( method_exists( 'expHelp', 'carryReading' ) )
            {
                $sectionUrl = expHelp::carryReading( $sectionUrl );
            }
        }
        $excerpt = trim( preg_replace( '/\s+/u', ' ', isset( $document['summary'] ) ? (string)$document['summary'] : '' ) );
        $length = (int)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', 'ExcerptLength' );
        if ( mb_strlen( $excerpt ) > $length )
        {
            $excerpt = rtrim( mb_substr( $excerpt, 0, $length ) ) . '…';
        }
        $time = (int)$page['time'];
        return array( 'node' => false, 'title' => (string)$document['title'], 'url' => expDocFetch::helpViewerUrl( $page['id'] ),
                      'day' => date( 'Y-m-d', $time ), 'modified' => $time, 'type' => 'updated',
                      'manual' => false, 'version' => false, 'by' => false, 'updated_at' => 0, 'excerpt' => $excerpt,
                      'author' => false, 'published' => $time, 'published_day' => date( 'Y-m-d', $time ),
                      'help' => true, 'section' => $section, 'section_url' => $sectionUrl );
    }

    /**
     * The address of the view with these filters, as view parameters (never a query string), from the module's
     * alias ([RecentSettings] Path) on: "recent/(manual)/12/(range)/7d".
     *
     * @param array $filters
     * @param array $extra more view parameters (offset, limit, feed)
     * @param string $setting the [RecentSettings] address to start from: Path (the pages) or CommentsPath (the comments)
     * @return string
     */
    public static function uri( array $filters, array $extra = array(), $setting = 'Path' )
    {
        $uri = (string)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', $setting );
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
     * @param string $mode changed (newest change first, by the object's modified date) or new (pages newest first by
     *        the date they were first published on this site, the object's published date; historical copies left out)
     * @param bool $withHelp whether the list without filters takes the help's Markdown pages too (the front page's list
     *        does not: it has a box of its own for them)
     * @return array array( 'items' => list of entry hashes (see entry() and helpEntry()), 'count' => int )
     */
    public static function fetch( array $filters, $offset, $limit, $mode = 'changed', $withHelp = true )
    {
        $offset = max( 0, (int)$offset );
        $limit = max( 1, (int)$limit );
        $help = $mode !== 'new' && self::helpAvailable();
        $since = isset( $filters['range'] ) ? time() - self::$ranges[$filters['range']] : 0;
        if ( isset( $filters['manual'] ) && $filters['manual'] === self::HELP )
        {
            if ( !$help )
            {
                return array( 'items' => array(), 'count' => 0 );
            }
            $pages = self::helpPages( $since );
            return array( 'items' => self::helpEntries( array_slice( $pages, $offset, $limit ) ), 'count' => count( $pages ) );
        }
        $query = self::contentQuery( $filters, $mode );
        if ( $query === null )
        {
            return array( 'items' => array(), 'count' => 0 );
        }
        list( $params, $conditions, $parentID ) = $query;
        $count = self::contentCount( $params, $conditions, $parentID );
        // all manuals, no other filter but the range: the Markdown pages too, merged by date
        if ( !$help || !$withHelp || array_diff( array_keys( $filters ), array( 'range' ) ) )
        {
            return array( 'items' => self::contentEntries( $params, $conditions, $parentID, $offset, $limit ), 'count' => $count );
        }
        $pages = self::helpPages( $since );
        // how many Markdown pages come before the offset: the merged position of page b is the number of content
        // pages changed after it plus b (content first when newer, the Markdown page first on the same second), which
        // grows with b, so the first b whose position reaches the offset is found by halving, one count per step
        $low = max( 0, $offset - $count );
        $high = min( count( $pages ), $offset );
        while ( $low < $high )
        {
            $middle = intdiv( $low + $high, 2 );
            $after = array( 'modified', '>', $pages[$middle]['time'] );
            if ( self::contentCount( $params, array_merge( $conditions, array( $after ) ), $parentID ) + $middle >= $offset )
            {
                $high = $middle;
            }
            else
            {
                $low = $middle + 1;
            }
        }
        $content = self::contentEntries( $params, $conditions, $parentID, $offset - $low, $limit );
        $markdown = self::helpEntries( array_slice( $pages, $low, $limit ) );
        $items = array();
        while ( count( $items ) < $limit && ( $content || $markdown ) )
        {
            $items[] = !$markdown || ( $content && $content[0]['modified'] > $markdown[0]['modified'] )
                     ? array_shift( $content ) : array_shift( $markdown );
        }
        return array( 'items' => $items, 'count' => $count + count( $pages ) );
    }

    /**
     * The entries of help pages (helpEntry()), leaving out a page the index no longer has.
     *
     * @param array $pages of helpPages()
     * @return array
     */
    protected static function helpEntries( array $pages )
    {
        $items = array();
        foreach ( $pages as $page )
        {
            $entry = self::helpEntry( $page );
            if ( $entry !== null )
            {
                $items[] = $entry;
            }
        }
        return $items;
    }

    /**
     * The fetch parameters of the content pages: array( params (without AttributeFilter), conditions (the attribute
     * filter's conditions, joined by and), parent node id ), or null when nothing can match.
     *
     * @param array $filters
     * @param string $mode
     * @return array|null
     */
    protected static function contentQuery( array $filters, $mode )
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
        if ( $mode === 'new' )
        {
            $classes = array_values( array_diff( $classes, (array)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', 'HistoryClasses' ) ) );
        }
        $params = array( 'ClassFilterType' => 'include', 'ClassFilterArray' => $classes, 'MainNodeOnly' => true,
                         'SortBy' => array( $mode === 'new' ? 'published' : 'modified', false ) );
        $attributeFilter = array();
        if ( isset( $filters['range'] ) )
        {
            $attributeFilter[] = array( $mode === 'new' ? 'published' : 'modified', '>=', time() - self::$ranges[$filters['range']] );
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
                return null;
            }
            $attributeFilter[] = count( $byClass ) === 2 ? $byClass[1] : $byClass;
        }
        return array( $params, $attributeFilter, $parentID );
    }

    /**
     * The parameters of contentQuery() with these attribute filter conditions.
     *
     * @param array $params
     * @param array $conditions
     * @return array
     */
    protected static function withConditions( array $params, array $conditions )
    {
        if ( $conditions )
        {
            $params['AttributeFilter'] = count( $conditions ) === 1 ? $conditions : array_merge( array( 'and' ), $conditions );
        }
        return $params;
    }

    /**
     * The number of content pages that match.
     *
     * @param array $params
     * @param array $conditions
     * @param int $parentID
     * @return int
     */
    protected static function contentCount( array $params, array $conditions, $parentID )
    {
        return (int)eZContentObjectTreeNode::subTreeCountByNodeID( self::withConditions( $params, $conditions ), $parentID );
    }

    /**
     * One page of the content pages' entries (entry()).
     *
     * @param array $params
     * @param array $conditions
     * @param int $parentID
     * @param int $offset
     * @param int $limit
     * @return array
     */
    protected static function contentEntries( array $params, array $conditions, $parentID, $offset, $limit )
    {
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array_merge( self::withConditions( $params, $conditions ),
                                                                        array( 'Offset' => (int)$offset, 'Limit' => (int)$limit ) ), $parentID );
        $items = array();
        foreach ( is_array( $nodes ) ? $nodes : array() as $node )
        {
            $items[] = self::entry( $node );
        }
        return $items;
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
        // the writer (written_by), for the new pages
        $author = isset( $map['written_by'] ) && $map['written_by']->hasContent() ? eZContentObject::fetch( (int)$map['written_by']->attribute( 'data_int' ) ) : false;
        $published = (int)$object->attribute( 'published' );
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
                      'updated_at' => $updatedAt, 'excerpt' => $excerpt,
                      'author' => $author instanceof eZContentObject ? $author : false, 'published' => $published,
                      'published_day' => date( 'Y-m-d', $published ), 'help' => false, 'section' => '', 'section_url' => false );
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
     * (objects, by name), and help: whether the Markdown pages of the help center are a choice (the manual help and the
     * kind markdown, which then ends the classes; only when asked for).
     *
     * @param bool $withHelp whether the Markdown pages are a choice (the recent changes, not the pages added)
     * @return array
     */
    public static function options( $withHelp = false )
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
        $help = $withHelp && self::helpAvailable();
        if ( $help )
        {
            $classes[self::HELP_KIND] = ezpI18n::tr( 'design/exp_doc', 'Markdown page' );
        }
        return array( 'manuals' => is_array( $manuals ) ? $manuals : array(), 'versions' => $versions,
                      'classes' => $classes, 'contributors' => $contributors, 'ranges' => array_keys( self::$ranges ),
                      'help' => $help );
    }

    /**
     * The front page's lists (fetch exp_doc/recent_pages): the newest entries of a mode, without filters.
     *
     * @param string $mode changed or new
     * @param int $limit
     * @return array array( 'result' => entries of fetch() )
     */
    public static function latest( $mode, $limit )
    {
        // fetch() without its count: the list never says how many there are, and the count is a query over every
        // page of its own
        $query = self::contentQuery( array(), $mode === 'new' ? 'new' : 'changed' );
        if ( $query === null )
        {
            return array( 'result' => array() );
        }
        list( $params, $conditions, $parentID ) = $query;
        return array( 'result' => self::contentEntries( $params, $conditions, $parentID, 0, max( 1, (int)$limit ) ) );
    }

    /**
     * The copyright line of the feeds (as the footer has it, without the link): "Copyright © 1998 - <this year>
     * Exponential Foundation and 7x (except where otherwise noted)."
     *
     * @return string
     */
    public static function rights()
    {
        return ezpI18n::tr( 'design/exp_doc', 'Copyright © 1998 - %year %maker (except where otherwise noted).', null,
                            array( '%year' => date( 'Y' ),
                                   '%maker' => ezpI18n::tr( 'design/exp_doc', 'Exponential Foundation and %company', null, array( '%company' => '7x' ) ) ) );
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
             . '  <author><name>' . $esc( $title ) . "</name></author>\n"
             . '  <rights>' . $esc( self::rights() ) . "</rights>\n";
        foreach ( $items as $item )
        {
            $url = $item['url'];
            eZURI::transformURI( $url );
            $url = $base . $url;
            $context = array();
            if ( $item['manual'] ) { $context[] = $item['manual']->attribute( 'name' ); }
            if ( $item['version'] ) { $context[] = $item['version']->attribute( 'name' ); }
            if ( !empty( $item['help'] ) ) { $context[] = ezpI18n::tr( 'design/exp_doc', 'Markdown documentation (help center)' ); }
            if ( !empty( $item['section'] ) ) { $context[] = $item['section']; }
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
