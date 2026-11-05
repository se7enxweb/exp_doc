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
     * comment class's author relation: how many, and the newest one's written date). Aggregate queries, one per role,
     * never one per person. Split by role: authors (at least one page; most pages first, then by name), commenters
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
        // the comments: the historical comments' author relation, how many and the newest one's written date, in one
        // aggregate (the readers' new comments name their author as text, so they are not counted here)
        $commentClass = (string)$ini->variable( 'ClassicSettings', 'CommentClass' );
        $classAttribute = function ( $identifier ) use ( $db, $commentClass )
        {
            $rows = $db->arrayQuery( "SELECT a.id FROM ezcontentclass_attribute a, ezcontentclass c WHERE a.version = 0 AND c.version = 0
                                      AND a.contentclass_id = c.id AND c.identifier = '" . $db->escapeString( $commentClass ) . "'
                                      AND a.identifier = '" . $db->escapeString( $identifier ) . "'" );
            return $rows ? (int)$rows[0]['id'] : 0;
        };
        $comments = array();
        $authorAttribute = $classAttribute( 'author' );
        $createdAttribute = $classAttribute( 'created' );
        if ( $authorAttribute )
        {
            foreach ( $db->arrayQuery( "SELECT ca.data_int AS id, COUNT(*) AS n, MAX( cd.data_int ) AS latest
                                        FROM ezcontentobject_attribute ca, ezcontentobject o, ezcontentobject_attribute cd
                                        WHERE ca.contentclassattribute_id = $authorAttribute AND ca.data_int > 0
                                        AND o.id = ca.contentobject_id AND o.current_version = ca.version AND o.status = 1
                                        AND cd.contentobject_id = ca.contentobject_id AND cd.version = ca.version
                                        AND cd.language_code = ca.language_code AND cd.contentclassattribute_id = " . (int)$createdAttribute . "
                                        GROUP BY ca.data_int" ) as $row )
            {
                $comments[(int)$row['id']] = array( (int)$row['n'], (int)$row['latest'] );
            }
        }
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
                foreach ( array( 'short_description', 'summary', 'intro' ) as $identifier )
                {
                    if ( isset( $map[$identifier] ) && $map[$identifier]->hasContent() )
                    {
                        $entry['text'] = trim( preg_replace( '/\s+/u', ' ', strip_tags( $map[$identifier]->attribute( 'data_text' ) ) ) );
                        break;
                    }
                }
                if ( isset( $map['status'] ) && $map['status']->hasContent() )
                {
                    $entry['status'] = strtolower( trim( $map['status']->toString() ) );
                }
            }
            $result[] = $entry;
        }
        return array( 'result' => $result );
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
