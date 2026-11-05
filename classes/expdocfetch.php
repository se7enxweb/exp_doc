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

    /** @var bool whether the stored map (var/<site>/cache/exp_doc/node-by-source.php) was read in this request */
    protected static $cacheLoaded = false;

    /**
     * The node imported from a static file: the main node of the object whose source_path attribute equals $path
     * (relative to the static repository's root, without a leading slash). Only the published version counts.
     *
     * The answers are kept in a cache file until the next publish (the template-block expiry every publish sets):
     * Classic's frame looks up the same twenty paths on every page (the quick links, the caution box, the path, the
     * footer), and a path no page was imported from (documentation.html) cost a search through every source_path
     * attribute, seconds per page view.
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
        if ( !self::$cacheLoaded )
        {
            self::$cacheLoaded = true;
            self::$cache = array_merge( self::readSourceCache(), self::$cache );
        }
        if ( !array_key_exists( $path, self::$cache ) )
        {
            self::$cache[$path] = self::lookup( $path );
            self::writeSourceCache();
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
        // comment authors, by name (author_name, as the source wrote it; the old class kept it in author)
        $commented = array();
        $commentClass = eZINI::instance( 'exp_doc.ini' )->variable( 'ClassicSettings', 'CommentClass' );
        $comments = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( $commentClass ),
                                                                    'SortBy' => array( 'published', true ) ), $node->attribute( 'node_id' ) );
        foreach ( is_array( $comments ) ? $comments : array() as $comment )
        {
            $cmap = $comment->dataMap();
            $name = isset( $cmap['author_name'] ) ? $cmap['author_name']->toString() : ( isset( $cmap['author'] ) ? $cmap['author']->toString() : '' );
            $name = mb_strtolower( trim( $name ) );
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
     * The pages a contributor's page lists (fetch exp_doc/contributor_pages): the objects that name the person in any
     * relation (written_by, last_updated_by, maintainers, contributors), each by its main node, newest change first,
     * a page of them at a time. Only what a reader may open is counted and listed: visible main nodes (no hidden or
     * invisible ones), not of the classes the menus leave out (exp_doc.ini [ClassicSettings] MenuHideClasses[]:
     * historical copies, comments, images ...), and only nodes the current user may read.
     *
     * @param int $objectID the contributor object
     * @param int $offset
     * @param int $limit
     * @return array array( 'result' => array( 'nodes' => eZContentObjectTreeNode[], 'count' => int ) )
     */
    public static function contributorPages( $objectID, $offset = 0, $limit = 24 )
    {
        $db = eZDB::instance();
        $hide = array();
        foreach ( (array)eZINI::instance( 'exp_doc.ini' )->variable( 'ClassicSettings', 'MenuHideClasses' ) as $identifier )
        {
            $id = eZContentClass::classIDByIdentifier( $identifier );
            if ( $id ) { $hide[] = (int)$id; }
        }
        $where = "FROM ezcontentobject_link l, ezcontentobject o, ezcontentobject_tree t
                  WHERE l.to_contentobject_id = " . (int)$objectID . "
                  AND o.id = l.from_contentobject_id AND o.current_version = l.from_contentobject_version AND o.status = 1
                  AND t.contentobject_id = o.id AND t.node_id = t.main_node_id AND t.is_hidden = 0 AND t.is_invisible = 0"
               . ( $hide ? " AND o.contentclass_id NOT IN ( " . implode( ',', $hide ) . " )" : '' );
        $count = $db->arrayQuery( "SELECT COUNT( DISTINCT t.node_id ) AS n " . $where );
        $rows = $db->arrayQuery( "SELECT DISTINCT t.node_id, o.modified " . $where . " ORDER BY o.modified DESC, t.node_id",
                                 array( 'offset' => max( 0, (int)$offset ), 'limit' => max( 1, (int)$limit ) ) );
        $nodes = array();
        foreach ( $rows as $row )
        {
            $node = eZContentObjectTreeNode::fetch( (int)$row['node_id'] );
            if ( $node instanceof eZContentObjectTreeNode && $node->canRead() )
            {
                $nodes[] = $node;
            }
        }
        return array( 'result' => array( 'nodes' => $nodes, 'count' => $count ? (int)$count[0]['n'] : 0 ) );
    }

    /** @var array|null the people of the Contributors page, for the request (people()) */
    protected static $people = null;

    /**
     * The Contributors page's main list (fetch exp_doc/contributor_list): everyone with at least one authoring role,
     * most pages first; see people().
     *
     * @return array array( 'result' => entries of people() )
     */
    public static function contributorList()
    {
        $people = self::people();
        return array( 'result' => $people['authors'] );
    }

    /**
     * The Contributors page's "Commenters" (fetch exp_doc/commenter_list): the people whose only role is the author of
     * historical comments, most comments first; see people().
     *
     * @return array array( 'result' => entries of people() )
     */
    public static function commenterList()
    {
        $people = self::people();
        return array( 'result' => $people['commenters'] );
    }

    /**
     * Every contributor of the site: the exp_doc_contributor objects below the Contributors folder (exp_doc.ini
     * [RecentSettings] ContributorFolderRemoteID), each with the number of pages that name them as writer (written_by;
     * Confluence's "created by" is mapped there), last updater (last_updated_by, "last modified by") and maintainer
     * (maintainers), the current versions of published pages only, and the historical comments they wrote (the
     * comment class's author relation: how many, and the newest one's written date; expDocContributorCounts, kept per
     * publish by a cronjob part). Split by role: authors (at least one page; most pages first, then by name), commenters
     * (comments only; most comments first, then by name), and the count of those with neither (their comments not
     * converted yet).
     *
     * @return array array( 'authors', 'commenters' => list of array( 'object', 'node', 'name', 'written', 'updated',
     *               'maintained', 'total', 'comments', 'last_comment', 'roles' ), 'neither' => int )
     */
    protected static function people()
    {
        if ( self::$people !== null )
        {
            return self::$people;
        }
        $ini = eZINI::instance( 'exp_doc.ini' );
        $folder = eZContentObject::fetchByRemoteID( (string)$ini->variable( 'RecentSettings', 'ContributorFolderRemoteID' ) );
        $result = array( 'authors' => array(), 'commenters' => array(), 'neither' => 0 );
        if ( !$folder || !$folder->mainNode() )
        {
            return self::$people = $result;
        }
        // the role counts, counted once per publish by the cronjob part exp_doc_contributor_counts.php and kept in a
        // cache file (expDocContributorCounts), not by every view of the page
        $all = expDocContributorCounts::get();
        $counts = array( 'written' => $all['written'], 'updated' => $all['updated'], 'maintained' => $all['maintained'] );
        $comments = $all['comments'];
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( 'exp_doc_contributor' ),
                                                                 'Depth' => 1, 'DepthOperator' => 'eq' ),
                                                          $folder->mainNode()->attribute( 'node_id' ) );
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
            $entry['comments'] = isset( $comments[$id] ) ? $comments[$id][0] : 0;
            $entry['last_comment'] = isset( $comments[$id] ) ? $comments[$id][1] : 0;
            if ( $entry['comments'] ) { $roles[] = 'commenter'; }
            $entry['roles'] = $roles;
            if ( $entry['total'] )
            {
                $result['authors'][] = $entry;
            }
            elseif ( $entry['comments'] )
            {
                $result['commenters'][] = $entry;
            }
            else
            {
                $result['neither']++;
            }
        }
        usort( $result['authors'], function ( $a, $b )
        {
            return $b['total'] <=> $a['total'] ?: strcasecmp( $a['name'], $b['name'] );
        } );
        usort( $result['commenters'], function ( $a, $b )
        {
            return $b['comments'] <=> $a['comments'] ?: strcasecmp( $a['name'], $b['name'] );
        } );
        return self::$people = $result;
    }

    /**
     * The products of the front page (exp_doc.ini [ModernSettings] ProductList[]: "<path>;<name>;<one line>[;<status>]"),
     * in that order. The name is always the setting's (the owner's product names); the short text and the status come
     * from the product's container node when it exists at that path below the site's root, else from the setting, so
     * the cards are there before the containers are.
     *
     * @return array array( 'result' => list of array( 'path', 'node' (or false), 'name', 'text', 'status' ) )
     */
    public static function products()
    {
        $prefix = eZURLAliasML::getPathPrefix();
        $result = array();
        foreach ( (array)eZINI::instance( 'exp_doc.ini' )->variable( 'ModernSettings', 'ProductList' ) as $line )
        {
            $parts = array_map( 'trim', explode( ';', (string)$line ) );
            if ( count( $parts ) < 2 || $parts[0] === '' )
            {
                continue;
            }
            $path = trim( $parts[0], '/' );
            $entry = array( 'path' => $path, 'node' => false, 'name' => $parts[1], 'text' => isset( $parts[2] ) ? $parts[2] : '',
                            'status' => isset( $parts[3] ) ? strtolower( $parts[3] ) : '' );
            $node = eZContentObjectTreeNode::fetchByURLPath( strtolower( ( $prefix ? $prefix . '/' : '' ) . $path ) );
            if ( $node instanceof eZContentObjectTreeNode && $node->canRead() )
            {
                $map = $node->dataMap();
                $entry['node'] = $node;
                $text = '';
                foreach ( array( 'short_description', 'summary', 'intro' ) as $identifier )
                {
                    if ( isset( $map[$identifier] ) && $map[$identifier]->hasContent() )
                    {
                        $text = trim( preg_replace( '/\s+/u', ' ', strip_tags( $map[$identifier]->attribute( 'data_text' ) ) ) );
                        break;
                    }
                }
                // a section (exp_doc_section has none of those): the description of its Metadata attribute, which
                // editors change in the same edit form
                if ( $text === '' && isset( $map['metadata'] ) && $map['metadata']->attribute( 'data_type_string' ) === 'xrowmetadata' )
                {
                    $meta = $map['metadata']->content();
                    if ( is_object( $meta ) && isset( $meta->description ) )
                    {
                        $text = trim( preg_replace( '/\s+/u', ' ', (string)$meta->description ) );
                    }
                }
                if ( $text !== '' )
                {
                    $entry['text'] = $text;
                }
                if ( isset( $map['status'] ) && $map['status']->hasContent() )
                {
                    $entry['status'] = strtolower( trim( $map['status']->toString() ) );
                }
            }
            $result[] = $entry;
        }
        return array( 'result' => self::$productList = $result );
    }

    /** @var array|null the products of the request (products()), read once */
    protected static $productList = null;

    /**
     * The path of the product ([ModernSettings] ProductList[]) whose container $node is, compared with the node's
     * address (without the site's path prefix), so no query is made; false when the node is no product's container.
     *
     * @param eZContentObjectTreeNode $node
     * @return string|false
     */
    public static function productKey( eZContentObjectTreeNode $node )
    {
        $alias = strtolower( trim( (string)$node->attribute( 'url_alias' ), '/' ) );
        $prefix = strtolower( trim( (string)eZURLAliasML::getPathPrefix(), '/' ) );
        if ( $prefix !== '' && strpos( $alias, $prefix . '/' ) === 0 )
        {
            $alias = substr( $alias, strlen( $prefix ) + 1 );
        }
        if ( $alias === '' )
        {
            return false;
        }
        foreach ( (array)eZINI::instance( 'exp_doc.ini' )->variable( 'ModernSettings', 'ProductList' ) as $line )
        {
            $parts = explode( ';', (string)$line, 2 );
            $path = strtolower( trim( trim( $parts[0] ), '/' ) );
            if ( $path !== '' && $path === $alias )
            {
                return $path;
            }
        }
        return false;
    }

    /**
     * Whether the node is a product's container (the Classic pagelayout loads the help center's styles for its box).
     *
     * @param int $nodeID
     * @return array array( 'result' => bool )
     */
    public static function isProduct( $nodeID )
    {
        $node = eZContentObjectTreeNode::fetch( (int)$nodeID );
        return array( 'result' => $node instanceof eZContentObjectTreeNode && self::productKey( $node ) !== false );
    }

    /**
     * The landing page of a product's container (exp_doc.ini [ProductLandingSettings] and [ProductLanding_<path with
     * "_" for "/">]): the product's front page entry (name, text, status) with its supported flag, the product it
     * belongs to (the longest other product path before its own), its links, its sections (the container's children
     * without [ProductLandingSettings] HideSectionClasses[], at most MaxSections, each with its page count, the
     * product it is, and a manual's versions), the sections elsewhere on the site that belong to it (Related[]), its
     * recently changed pages (below the container; with nothing below it, below the related sections), the node of
     * the "see all changes" link, whether the landing shows the container's body, and the whole family (every product,
     * the current one marked). False when the node is no product's container.
     *
     * @param int $nodeID
     * @return array array( 'result' => array|false )
     */
    public static function productLanding( $nodeID )
    {
        $node = eZContentObjectTreeNode::fetch( (int)$nodeID );
        $key = $node instanceof eZContentObjectTreeNode ? self::productKey( $node ) : false;
        if ( $key === false )
        {
            return array( 'result' => false );
        }
        $ini = eZINI::instance( 'exp_doc.ini' );
        $group = 'ProductLanding_' . str_replace( '/', '_', $key );
        $setting = function ( $section, $name, $default ) use ( $ini )
        {
            return $ini->hasVariable( $section, $name ) ? $ini->variable( $section, $name ) : $default;
        };
        $supportedStatuses = (array)$setting( 'ModernSettings', 'SupportedStatuses', array() );
        $products = self::$productList !== null ? self::$productList : self::products()['result'];
        $current = false;
        $parent = false;
        $family = array();
        foreach ( $products as $product )
        {
            $product['current'] = $product['path'] === $key;
            $product['supported'] = $product['status'] !== '' && in_array( $product['status'], $supportedStatuses, true );
            if ( $product['current'] )
            {
                $current = $product;
            }
            elseif ( strpos( $key, $product['path'] . '/' ) === 0 && ( !$parent || strlen( $product['path'] ) > strlen( $parent['path'] ) ) )
            {
                $parent = $product;
            }
            $family[] = $product;
        }
        if ( !$current )
        {
            return array( 'result' => false );
        }

        $links = array();
        foreach ( (array)$setting( $group, 'Links', array() ) as $line )
        {
            $parts = array_map( 'trim', explode( ';', (string)$line, 2 ) );
            if ( count( $parts ) === 2 && $parts[0] !== '' && $parts[1] !== '' )
            {
                $links[] = array( 'kind' => strtolower( $parts[0] ), 'url' => $parts[1], 'external' => strpos( $parts[1], '://' ) !== false );
            }
        }

        $pageClasses = (array)$setting( 'ModernSettings', 'PageClasses', array() );
        $hide = (array)$setting( 'ProductLandingSettings', 'HideSectionClasses', array() );
        $params = array( 'Depth' => 1, 'DepthOperator' => 'eq', 'SortBy' => $node->sortArray() );
        if ( $hide )
        {
            $params['ClassFilterType'] = 'exclude';
            $params['ClassFilterArray'] = array_values( $hide );
        }
        $children = eZContentObjectTreeNode::subTreeByNodeID( $params, (int)$node->attribute( 'node_id' ) );
        $children = is_array( $children ) ? $children : array();
        $sections = array();
        foreach ( array_slice( $children, 0, max( 1, (int)$setting( 'ProductLandingSettings', 'MaxSections', 8 ) ) ) as $child )
        {
            $sections[] = self::productSection( $child, $family, $pageClasses );
        }

        $prefix = eZURLAliasML::getPathPrefix();
        $related = array();
        foreach ( (array)$setting( $group, 'Related', array() ) as $path )
        {
            $path = trim( (string)$path, '/' );
            $relatedNode = $path === '' ? null : eZContentObjectTreeNode::fetchByURLPath( strtolower( ( $prefix ? $prefix . '/' : '' ) . $path ) );
            if ( $relatedNode instanceof eZContentObjectTreeNode && $relatedNode->canRead() )
            {
                $related[] = self::productSection( $relatedNode, $family, $pageClasses, 'archive' );
            }
        }

        // the recently changed pages: below the container, or, with nothing below it, below its related sections
        $recentParents = array( (int)$node->attribute( 'node_id' ) );
        if ( !$children && $related )
        {
            $recentParents = array();
            foreach ( $related as $section )
            {
                $recentParents[] = (int)$section['node']->attribute( 'node_id' );
            }
        }
        $recent = array();
        if ( $pageClasses )
        {
            $recent = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => $pageClasses,
                                                                         'SortBy' => array( 'modified', false ),
                                                                         'Limit' => max( 1, (int)$setting( 'ProductLandingSettings', 'RecentLimit', 8 ) ) ),
                                                                  count( $recentParents ) === 1 ? $recentParents[0] : $recentParents );
            $recent = is_array( $recent ) ? $recent : array();
        }

        $map = $node->dataMap();
        return array( 'result' => array(
            'key' => $key,
            'node' => $node,
            'product' => $current,
            'parent' => $parent,
            'links' => $links,
            'sections' => $sections,
            'section_count' => count( $children ),
            'related' => $related,
            'recent' => $recent,
            // the "see all changes" link: the one node the list was taken from, else none
            'recent_node_id' => count( $recentParents ) === 1 ? $recentParents[0] : 0,
            'show_body' => $setting( $group, 'ShowBody', 'enabled' ) === 'enabled' && isset( $map['body'] ) && $map['body']->hasContent(),
            'family' => $family,
        ) );
    }

    /**
     * One section card of a product landing: the node, how many pages its subtree holds, the product it is (or
     * false), and a manual's versions.
     *
     * @param eZContentObjectTreeNode $node
     * @param array $family the products (productLanding())
     * @param array $pageClasses
     * @param string $icon the card's icon (a4-bi-<icon>); empty: a product's, a manual's or a section's
     * @return array
     */
    protected static function productSection( eZContentObjectTreeNode $node, array $family, array $pageClasses, $icon = '' )
    {
        $key = self::productKey( $node );
        $product = false;
        foreach ( $key === false ? array() : $family as $entry )
        {
            if ( $entry['path'] === $key )
            {
                $product = $entry;
            }
        }
        $isManual = $node->attribute( 'class_identifier' ) === 'exp_doc_manual';
        $versions = array();
        foreach ( $isManual ? self::versions( (int)$node->attribute( 'node_id' ) )['result'] : array() as $version )
        {
            $map = $version->dataMap();
            $label = isset( $map['version'] ) && $map['version']->hasContent() ? trim( $map['version']->toString() ) : '';
            $versions[] = array( 'node' => $version, 'label' => $label !== '' ? $label : (string)$version->attribute( 'name' ) );
        }
        return array(
            'node' => $node,
            // the product's name (the owner's) for a product, else the node's
            'name' => $product ? $product['name'] : (string)$node->attribute( 'name' ),
            'text' => $product ? $product['text'] : '',
            'supported' => $product ? $product['supported'] : false,
            'icon' => $icon !== '' ? $icon : ( $product ? 'box-seam' : ( $isManual ? 'journal-text' : 'folder' ) ),
            'count' => $pageClasses ? (int)eZContentObjectTreeNode::subTreeCountByNodeID( array( 'ClassFilterType' => 'include',
                                                                                                'ClassFilterArray' => $pageClasses ),
                                                                                         (int)$node->attribute( 'node_id' ) ) : 0,
            'product' => $product,
            'manual' => $isManual,
            'versions' => $versions,
        );
    }

    /**
     * The help center's "Support Exponential" block for the front page, exactly as the help dashboard gets it: the
     * kernel's exphelp/audience view builds it from exphelp.ini [SupportSettings] and [SupportOrganization_<id>], so the
     * texts, addresses and translations are never kept twice. False when the help is off, the block is off, or the
     * kernel is older than the block.
     *
     * @return array array( 'result' => array( 'title', 'text', 'organizations', 'more' )|false )
     */
    public static function helpSupport()
    {
        $class = 'Exponential\\View\\Kernel\\Exphelp\\Audience';
        if ( !class_exists( 'expHelp' ) || !expHelp::isEnabled() || !class_exists( $class ) || !method_exists( $class, 'support' ) )
        {
            return array( 'result' => false );
        }
        return array( 'result' => $class::support() );
    }

    /**
     * The help center's "Found an error?" block for the front page, as the help dashboard gets it: the address of the
     * reporting guide and the issue trackers of exphelp.ini (expHelpIssueReport), their labels translated. Where
     * site.ini [SiteAccessRules] switches exphelp/report off (the documentation site does: it tells about the
     * installation), the guide is the help page exphelp.ini [ContextHelp] Map[exphelp/report] names, and the security
     * link its "Security problems" section, so no link of the block ends on an error page.
     *
     * @return array array( 'result' => array( 'url', 'security', 'trackers' )|false )
     */
    public static function helpReport()
    {
        if ( !class_exists( 'expHelp' ) || !expHelp::isEnabled() || !class_exists( 'expHelpIssueReport' ) )
        {
            return array( 'result' => false );
        }
        $url = expHelp::url( 'report' );
        $security = $url . '#security';
        $access = eZModule::accessAllowed( new eZURI( 'exphelp/report' ) );
        if ( !$access['result'] )
        {
            $map = (array)expHelp::setting( 'ContextHelp', 'Map', array() );
            $page = isset( $map['exphelp/report'] ) ? (string)$map['exphelp/report'] : '';
            $url = $page !== '' ? expHelp::url( 'viewer', $page ) : expHelp::url( 'dashboard' );
            $security = $page !== '' ? $url . '#security-problems' : $url;
        }
        $report = new expHelpIssueReport();
        return array( 'result' => array( 'url' => $url,
                                         'security' => $security,
                                         'trackers' => expHelp::translatedNames( $report->trackers(), array( 'label', 'description' ) ) ) );
    }

    /**
     * The help's Markdown pages changed last, for the front page's "Recent Markdown changes": the same list as the
     * developers' help page's "Recently updated" (expHelpDocumentIndex::recentChanges(), the pages this reader may
     * read, in the reader's help language). Each address is the help viewer's and keeps the reader's help language
     * (/(lang)/<key>, expHelp::carryReading()) when one is chosen. An empty list when the help is off or the kernel is
     * older than the list.
     *
     * @param int $limit
     * @return array array( 'result' => list of array( 'id', 'title', 'subject', 'time', 'url' ) )
     */
    public static function helpRecentChanges( $limit = 8 )
    {
        if ( !class_exists( 'expHelp' ) || !expHelp::isEnabled() || !class_exists( 'expHelpDocumentIndex' )
             || !method_exists( 'expHelpDocumentIndex', 'recentChanges' ) )
        {
            return array( 'result' => array() );
        }
        $result = array();
        foreach ( expHelpDocumentIndex::instance()->recentChanges( min( 50, max( 1, (int)$limit ) ) ) as $change )
        {
            $result[] = array( 'id' => $change['id'],
                               'title' => $change['title'],
                               'subject' => isset( $change['subject'] ) ? (string)$change['subject'] : '',
                               'time' => isset( $change['time'] ) ? (int)$change['time'] : 0,
                               'url' => self::helpViewerUrl( $change['id'] ) );
        }
        return array( 'result' => $result );
    }

    /**
     * The help viewer's address of a help page, keeping the reader's help language (/(lang)/<key>,
     * expHelp::carryReading()) when one is chosen; module-relative, for |ezurl or eZURI::transformURI().
     *
     * @param string $id the page's id in the help index
     * @return string
     */
    public static function helpViewerUrl( $id )
    {
        $url = expHelp::url( 'viewer', $id );
        return method_exists( 'expHelp', 'carryReading' ) ? expHelp::carryReading( $url ) : $url;
    }

    /**
     * The latest commits of the Exponential repository for the front page's "Recent commits", as the developers' help
     * page gets them: the kernel's expHelpCommitFeed (exphelp.ini [CommitFeed]), which reads the project's feed on the
     * server at most once per its cache time, with its timeout and a lock, and otherwise answers from its cache; the
     * browser loads nothing from outside. Merge commits are left out. Also the address of the developers' page's
     * commit log (keeping the reader's help language). False when the help is off or the kernel has no feed.
     *
     * @param int $limit
     * @return array array( 'result' => array( 'commits', 'fetched', 'stale', 'error', 'history', 'more' )|false )
     */
    public static function helpCommits( $limit = 8 )
    {
        if ( !class_exists( 'expHelp' ) || !expHelp::isEnabled() || !class_exists( 'expHelpCommitFeed' )
             || !method_exists( 'expHelpCommitFeed', 'page' ) )
        {
            return array( 'result' => false );
        }
        $feed = new expHelpCommitFeed();
        $result = $feed->page( 0, min( 50, max( 1, (int)$limit ) ), false );
        $more = expHelp::url( 'audience', 'developer', 'commits' );
        $result['more'] = method_exists( 'expHelp', 'carryReading' ) ? expHelp::carryReading( $more ) : $more;
        return array( 'result' => $result );
    }

    /**
     * The newest topics and replies of the Exponential Share forums for the front page's "Recent forum activity":
     * expDocForumFeed, which reads the forums' RSS feed on the server with the kernel commit feed's timeout, lock and
     * cache (the browser loads nothing from outside). False when ForumFeedURL is empty or the kernel has no
     * expHelpCommitFeed to build on.
     *
     * @param int|false $limit false: [ModernSettings] ForumFeedLimit
     * @return array array( 'result' => array( 'items', 'fetched', 'stale', 'error', 'more' )|false )
     */
    public static function forumActivity( $limit = false )
    {
        if ( !class_exists( 'expHelpCommitFeed' ) || !method_exists( 'expHelpCommitFeed', 'commits' )
             || !class_exists( 'expDocForumFeed' ) )
        {
            return array( 'result' => false );
        }
        $feed = new expDocForumFeed();
        $options = $feed->options();
        if ( !$options['enabled'] )
        {
            return array( 'result' => false );
        }
        return array( 'result' => $feed->items( $limit === false || $limit === null ? null : (int)$limit ) );
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
     * @param int $offset the visible children to skip first (paging counts only the children the menus show)
     * @return array array( 'result' => eZContentObjectTreeNode[] )
     */
    public static function menuChildren( $parentNodeID, $limit = false, $offset = 0 )
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
            $params['Limit'] = max( 0, (int)$offset ) + (int)$limit + count( $hideNodes );
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
            // by the node's remote id or its object's (the migrations name the objects)
            if ( !in_array( $child->attribute( 'remote_id' ), $hideNodes, true )
                 && !in_array( $child->object()->attribute( 'remote_id' ), $hideNodes, true ) )
            {
                $result[] = $child;
            }
        }
        if ( ( $limit && (int)$limit > 0 ) || (int)$offset > 0 )
        {
            $result = array_slice( $result, max( 0, (int)$offset ), $limit && (int)$limit > 0 ? (int)$limit : null );
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
        // a manual whose versions are not below it (the tree of 2026-11-04: /exponential/<version>/<manual>): the
        // versions of that manual are the manuals of the same address inside each version next to the manual
        $parent = $nodes ? null : eZContentObjectTreeNode::fetch( (int)$parentNodeID );
        if ( $parent instanceof eZContentObjectTreeNode && $parent->attribute( 'class_identifier' ) === 'exp_doc_manual' )
        {
            $slug = basename( (string)$parent->attribute( 'url_alias' ) );
            $containers = eZContentObjectTreeNode::subTreeByNodeID( array( 'Depth' => 1, 'DepthOperator' => 'eq',
                                                                          'ClassFilterType' => 'include',
                                                                          'ClassFilterArray' => array( 'exp_doc_version' ) ), (int)$parent->attribute( 'parent_node_id' ) );
            foreach ( is_array( $containers ) ? $containers : array() as $container )
            {
                $children = eZContentObjectTreeNode::subTreeByNodeID( array( 'Depth' => 1, 'DepthOperator' => 'eq',
                                                                            'ClassFilterType' => 'include',
                                                                            'ClassFilterArray' => array( 'exp_doc_version' ) ), (int)$container->attribute( 'node_id' ) );
                foreach ( is_array( $children ) ? $children : array() as $child )
                {
                    if ( basename( (string)$child->attribute( 'url_alias' ) ) === $slug )
                    {
                        $nodes[] = $child;
                    }
                }
            }
        }
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
    /** @return string the cache file of nodeBySource() */
    protected static function sourceCacheFile()
    {
        return eZSys::cacheDirectory() . '/exp_doc/node-by-source.php';
    }

    /**
     * The stored path => node id map, empty when there is none or something was published after it was written.
     *
     * @return array
     */
    protected static function readSourceCache()
    {
        $file = self::sourceCacheFile();
        if ( !is_file( $file ) )
        {
            return array();
        }
        $data = @include $file;
        if ( !is_array( $data ) || !isset( $data['time'], $data['map'] ) || !is_array( $data['map'] )
             || (int)$data['time'] <= (int)eZExpiryHandler::instance()->getTimestamp( 'template-block-cache', 0 ) )
        {
            return array();
        }
        return $data['map'];
    }

    /** Stores the request's path => node id map (written whole and renamed, so a page view never reads half a file). */
    protected static function writeSourceCache()
    {
        $file = self::sourceCacheFile();
        $dir = dirname( $file );
        if ( !is_dir( $dir ) && !eZDir::mkdir( $dir, false, true ) )
        {
            return;
        }
        $tmp = $file . '.' . getmypid() . '.tmp';
        $data = array( 'time' => time(), 'map' => array_map( 'intval', self::$cache ) );
        if ( @file_put_contents( $tmp, '<?php return ' . var_export( $data, true ) . ";\n" ) !== false )
        {
            @chmod( $tmp, 0666 );
            @rename( $tmp, $file );
            if ( function_exists( 'opcache_invalidate' ) )
            {
                opcache_invalidate( $file, true );
            }
        }
    }

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
        $conditions = array( 'contentclassattribute_id' => array( $classAttributeIDs ), 'data_text' => $path );
        // the string datatype's sort key is the lower-case text (at most 255 characters): its index narrows the rows
        // to the few with this text, where data_text alone reads every source_path attribute (seconds)
        $sortKey = eZCharTransform::instance()->transformByGroup( $path, 'lowercase' );
        if ( strlen( $sortKey ) <= 255 )
        {
            $conditions['sort_key_string'] = $sortKey;
        }
        $attributes = eZPersistentObject::fetchObjectList( eZContentObjectAttribute::definition(), null, $conditions,
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

    /** @var array node id => the Confluence context of that node (confluenceContext()), for the request */
    protected static $confluence = array();

    /**
     * The Confluence frame of a page in the Classic design: whether the node comes from the former documentation
     * center's Confluence spaces (below the Confluence container, exp_doc.ini [PlatformSettings] RemoteID, or imported
     * from a static path whose first folder is one of [ClassicSettings] ConfluencePrefixes[]), and if so what the
     * static site's Atlassian frame showed around it:
     * - space: the space's node (the Confluence container's child on the node's path), key (its short title, USER),
     *   name (its name), home (the space's home page: its child on the node's path, else its child imported from
     *   display/<key>.html, else its first child);
     * - title: the page's title without the " - <space> - eZ Documentation" the import kept from the static <title>;
     * - crumbs: the pages from the space's home page down to the page's parent (the static breadcrumbs after the
     *   space), each array( 'node', 'title' );
     * - tree: the space's page tree (the home page's children as the menus list them, the branch down to the page
     *   opened), each item array( 'node', 'title', 'current', 'open', 'has_children', 'children' );
     * - attachments: the images and files the page relates to (exp_doc.ini [ConfluenceFrame] AttachmentClasses[]).
     * False for every other node. Computed once per request and node.
     *
     * @param int $nodeID
     * @return array array( 'result' => array|false )
     */
    public static function confluenceContext( $nodeID )
    {
        $nodeID = (int)$nodeID;
        if ( !array_key_exists( $nodeID, self::$confluence ) )
        {
            self::$confluence[$nodeID] = self::buildConfluenceContext( $nodeID );
        }
        return array( 'result' => self::$confluence[$nodeID] );
    }

    /**
     * @param int $nodeID
     * @return array|false
     */
    protected static function buildConfluenceContext( $nodeID )
    {
        $node = $nodeID ? eZContentObjectTreeNode::fetch( $nodeID ) : null;
        if ( !$node instanceof eZContentObjectTreeNode )
        {
            return false;
        }
        $ini = eZINI::instance( 'exp_doc.ini' );
        $container = $ini->hasVariable( 'PlatformSettings', 'RemoteID' ) ? eZContentObject::fetchByRemoteID( $ini->variable( 'PlatformSettings', 'RemoteID' ) ) : null;
        $containerNodeID = $container instanceof eZContentObject ? (int)$container->attribute( 'main_node_id' ) : 0;
        $path = array_map( 'intval', $node->attribute( 'path_array' ) );
        $below = $containerNodeID && in_array( $containerNodeID, $path, true ) && (int)$node->attribute( 'node_id' ) !== $containerNodeID;
        $dataMap = $node->attribute( 'data_map' );
        $source = isset( $dataMap['source_path'] ) ? trim( (string)$dataMap['source_path']->attribute( 'data_text' ) ) : '';
        $prefixes = $ini->hasVariable( 'ClassicSettings', 'ConfluencePrefixes' ) ? (array)$ini->variable( 'ClassicSettings', 'ConfluencePrefixes' ) : array();
        $bySource = $source !== '' && in_array( strtok( ltrim( $source, '/' ), '/' ), $prefixes, true );
        if ( !$below && !$bySource )
        {
            return false;
        }

        // the space: the container's child on the node's path (the node itself when it is a space)
        $space = null;
        if ( $below )
        {
            $at = array_search( $containerNodeID, $path, true );
            if ( isset( $path[$at + 1] ) )
            {
                $space = $path[$at + 1] === (int)$node->attribute( 'node_id' ) ? $node : eZContentObjectTreeNode::fetch( $path[$at + 1] );
            }
        }
        $key = '';
        $name = '';
        $home = null;
        if ( $space instanceof eZContentObjectTreeNode )
        {
            $spaceMap = $space->attribute( 'data_map' );
            $key = isset( $spaceMap['short_title'] ) ? trim( (string)$spaceMap['short_title']->attribute( 'data_text' ) ) : '';
            if ( $key === '' && isset( $spaceMap['source_path'] ) )
            {
                $key = basename( rtrim( (string)$spaceMap['source_path']->attribute( 'data_text' ), '/' ) );
            }
            $name = (string)$space->attribute( 'name' );
            $children = self::menuChildren( $space->attribute( 'node_id' ) );
            // the space's page on the node's path (the root of the space's tree the page sits in), else the page
            // imported from the space's start file, else the first
            foreach ( $children['result'] as $child )
            {
                if ( in_array( (int)$child->attribute( 'node_id' ), $path, true ) )
                {
                    $home = $child;
                    break;
                }
            }
            foreach ( $home ? array() : $children['result'] as $child )
            {
                $childMap = $child->attribute( 'data_map' );
                if ( isset( $childMap['source_path'] ) && trim( (string)$childMap['source_path']->attribute( 'data_text' ) ) === 'display/' . $key . '.html' )
                {
                    $home = $child;
                    break;
                }
            }
            if ( !$home && $children['result'] )
            {
                $home = $children['result'][0];
            }
        }
        else
        {
            $space = null;
        }

        // the breadcrumbs: from the home page down to the parent
        $crumbs = array();
        if ( $home instanceof eZContentObjectTreeNode && in_array( (int)$home->attribute( 'node_id' ), $path, true )
             && (int)$home->attribute( 'node_id' ) !== (int)$node->attribute( 'node_id' ) )
        {
            $from = array_search( (int)$home->attribute( 'node_id' ), $path, true );
            foreach ( array_slice( $path, $from, -1 ) as $crumbID )
            {
                $crumb = eZContentObjectTreeNode::fetch( $crumbID );
                if ( $crumb instanceof eZContentObjectTreeNode && $crumb->canRead() )
                {
                    $crumbs[] = array( 'node' => $crumb, 'title' => self::confluenceTitle( $crumb->attribute( 'name' ) ) );
                }
            }
        }

        // the page tree: the home page's children, the branch down to the page opened
        $tree = $home instanceof eZContentObjectTreeNode ? self::confluenceTree( (int)$home->attribute( 'node_id' ), $path, (int)$node->attribute( 'node_id' ), 0 ) : array();

        // the attachments: the images and files the page relates to
        $attachments = array();
        $classes = $ini->hasVariable( 'ConfluenceFrame', 'AttachmentClasses' ) ? (array)$ini->variable( 'ConfluenceFrame', 'AttachmentClasses' ) : array();
        if ( $classes )
        {
            $related = $node->object()->relatedObjects( false, false, 0, false, array( 'AllRelations' => true ) );
            foreach ( is_array( $related ) ? $related : array() as $object )
            {
                if ( in_array( $object->attribute( 'class_identifier' ), $classes, true ) && $object->attribute( 'main_node_id' ) && $object->canRead() )
                {
                    $attachments[$object->attribute( 'id' )] = $object;
                }
            }
        }

        return array( 'space' => $space, 'key' => $key, 'name' => $name, 'home' => $home,
                      'title' => self::confluenceTitle( $node->attribute( 'name' ) ),
                      'crumbs' => $crumbs, 'tree' => $tree, 'attachments' => array_values( $attachments ) );
    }

    /**
     * A Confluence page's title as the static page showed it: the name without the " - <space> - eZ Documentation"
     * the import kept from the static <title> ("API - Developer - eZ Documentation" is "API").
     *
     * @param string $name
     * @return string
     */
    public static function confluenceTitle( $name )
    {
        $parts = explode( ' - ', (string)$name );
        if ( count( $parts ) >= 3 && trim( end( $parts ) ) === 'eZ Documentation' )
        {
            return implode( ' - ', array_slice( $parts, 0, -2 ) );
        }
        return (string)$name;
    }

    /**
     * One level of a space's page tree (confluenceContext()), and below it the level of the child on the page's path.
     *
     * @param int $parentNodeID
     * @param int[] $path the page's node path
     * @param int $currentID the page
     * @param int $depth the level, at most 12 deep
     * @return array
     */
    protected static function confluenceTree( $parentNodeID, array $path, $currentID, $depth )
    {
        $items = array();
        if ( $depth > 12 )
        {
            return $items;
        }
        $children = self::menuChildren( $parentNodeID );
        foreach ( $children['result'] as $child )
        {
            $childID = (int)$child->attribute( 'node_id' );
            $open = in_array( $childID, $path, true ) && $childID !== $currentID;
            $items[] = array( 'node' => $child, 'title' => self::confluenceTitle( $child->attribute( 'name' ) ),
                              'current' => $childID === $currentID, 'open' => $open,
                              'has_children' => (int)$child->attribute( 'children_count' ) > 0,
                              'children' => ( $open || $childID === $currentID ) ? self::confluenceTree( $childID, $path, $currentID, $depth + 1 ) : array() );
        }
        return $items;
    }
}
