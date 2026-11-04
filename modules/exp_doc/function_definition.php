<?php
/**
 * The template fetch functions of exp_doc.
 *
 *   fetch( 'exp_doc', 'node_by_source', hash( 'path', 'License.html' ) )
 *       the node imported from that static file (its source_path), or false; used by the Classic design's quick links,
 *       disclaimer and footer, so their links follow the pages wherever they move
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$FunctionList = array();
$FunctionList['node_by_source'] = array( 'name' => 'node_by_source',
                                         'operation_types' => array( 'read' ),
                                         'call_method' => array( 'class' => 'expDocFetch',
                                                                 'method' => 'nodeBySource' ),
                                         'parameter_type' => 'standard',
                                         'parameters' => array( array( 'name' => 'path',
                                                                       'type' => 'string',
                                                                       'required' => true ) ) );

/*
 *   fetch( 'exp_doc', 'versions', hash( 'parent_node_id', <manual node id> ) )
 *       the manual's version nodes (exp_doc_version), newest first by version number (6.x before 5.x before 4.7,
 *       compared as versions, not as text; "x" counts as the highest of its line)
 */
$FunctionList['versions'] = array( 'name' => 'versions',
                                   'operation_types' => array( 'read' ),
                                   'call_method' => array( 'class' => 'expDocFetch',
                                                           'method' => 'versions' ),
                                   'parameter_type' => 'standard',
                                   'parameters' => array( array( 'name' => 'parent_node_id',
                                                                 'type' => 'integer',
                                                                 'required' => true ) ) );

/*
 *   fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', <node id> ) ) [, 'limit', <n>]
 *       the children of a node as the menus list them: in the parent's sort order, without the classes of
 *       exp_doc.ini [ClassicSettings] MenuHideClasses[] and the nodes of MenuHideNodeRemoteIDs[] (the Contributors
 *       folder), at most limit of them; used by the Classic menus and Modern's page tree and child cards
 */
$FunctionList['menu_children'] = array( 'name' => 'menu_children',
                                        'operation_types' => array( 'read' ),
                                        'call_method' => array( 'class' => 'expDocFetch',
                                                                'method' => 'menuChildren' ),
                                        'parameter_type' => 'standard',
                                        'parameters' => array( array( 'name' => 'parent_node_id',
                                                                      'type' => 'integer',
                                                                      'required' => true ),
                                                               array( 'name' => 'limit',
                                                                      'type' => 'integer',
                                                                      'required' => false,
                                                                      'default' => false ) ) );

/*
 *   fetch( 'exp_doc', 'contributors', hash( 'node_id', <page node id> ) )
 *       everyone the page names (its contributors relation list, in its order), each as a hash: object, node (the
 *       contributor's page), name, roles (author, updated, maintainer, commenter) and dates (role => timestamp)
 */
$FunctionList['contributors'] = array( 'name' => 'contributors',
                                       'operation_types' => array( 'read' ),
                                       'call_method' => array( 'class' => 'expDocFetch',
                                                               'method' => 'contributors' ),
                                       'parameter_type' => 'standard',
                                       'parameters' => array( array( 'name' => 'node_id',
                                                                     'type' => 'integer',
                                                                     'required' => true ) ) );

/*
 *   fetch( 'exp_doc', 'contributor_list' )
 *       every contributor below the Contributors folder, each as a hash: object, node, name, written, updated,
 *       maintained (the number of pages that name them so), total and roles; most pages first
 */
$FunctionList['contributor_list'] = array( 'name' => 'contributor_list',
                                           'operation_types' => array( 'read' ),
                                           'call_method' => array( 'class' => 'expDocFetch',
                                                                   'method' => 'contributorList' ),
                                           'parameter_type' => 'standard',
                                           'parameters' => array() );

/*
 *   fetch( 'exp_doc', 'comment_thread', hash( 'node_id', <page or comment node id> ) )
 *       the readers' comments directly below a page or a comment, oldest first, as the reader may see them (a comment
 *       held for moderation is hidden, so readers never get it)
 */
$FunctionList['comment_thread'] = array( 'name' => 'comment_thread',
                                         'operation_types' => array( 'read' ),
                                         'call_method' => array( 'class' => 'expDocComment',
                                                                 'method' => 'thread' ),
                                         'parameter_type' => 'standard',
                                         'parameters' => array( array( 'name' => 'node_id',
                                                                       'type' => 'integer',
                                                                       'required' => true ) ) );

/*
 *   fetch( 'exp_doc', 'historical_comments', hash( 'node_id', <page node id> ) )
 *       the old site's comments of a page: hash( class, comments (directly below the page), total (with every
 *       reply, the page's own thread only) )
 */
$FunctionList['historical_comments'] = array( 'name' => 'historical_comments',
                                              'operation_types' => array( 'read' ),
                                              'call_method' => array( 'class' => 'expDocComment',
                                                                      'method' => 'historical' ),
                                              'parameter_type' => 'standard',
                                              'parameters' => array( array( 'name' => 'node_id',
                                                                            'type' => 'integer',
                                                                            'required' => true ) ) );

/*
 *   fetch( 'exp_doc', 'historical_comment', hash( 'node_id', <comment node id> ) )
 *       what a historical comment shows: name (the author, by the first value stored of the relation, author_name,
 *       the old author and the comment's own markup), contributor (node or false), date, body (the XML attribute with
 *       content, or '') and html (original_html when there is no body)
 */
$FunctionList['historical_comment'] = array( 'name' => 'historical_comment',
                                             'operation_types' => array( 'read' ),
                                             'call_method' => array( 'class' => 'expDocComment',
                                                                     'method' => 'historicalEntry' ),
                                             'parameter_type' => 'standard',
                                             'parameters' => array( array( 'name' => 'node_id',
                                                                           'type' => 'integer',
                                                                           'required' => true ) ) );

/*
 *   fetch( 'exp_doc', 'products' )
 *       the products of the front page, in the order of exp_doc.ini [ModernSettings] ProductList[]: path, node (the
 *       product's container, or false while it does not exist), name, text (one line) and status
 */
$FunctionList['products'] = array( 'name' => 'products',
                                   'operation_types' => array( 'read' ),
                                   'call_method' => array( 'class' => 'expDocFetch',
                                                           'method' => 'products' ),
                                   'parameter_type' => 'standard',
                                   'parameters' => array() );

/*
 *   fetch( 'exp_doc', 'recent_comments', hash( 'limit', 8 ) )
 *       the newest approved readers' comments (never a held one), each as a hash: node, page, subject, excerpt, name,
 *       date, type and anchor (the comment's id on its page)
 */
$FunctionList['recent_comments'] = array( 'name' => 'recent_comments',
                                          'operation_types' => array( 'read' ),
                                          'call_method' => array( 'class' => 'expDocComment',
                                                                  'method' => 'recentList' ),
                                          'parameter_type' => 'standard',
                                          'parameters' => array( array( 'name' => 'limit',
                                                                        'type' => 'integer',
                                                                        'required' => false,
                                                                        'default' => 8 ) ) );

/*
 *   fetch( 'exp_doc', 'recent_pages', hash( 'mode', 'new', 'limit', 8 ) )
 *       the newest pages: mode new (first published on this site, the object's published date) or changed (the
 *       newest change); each an entry of expDocRecent::entry() (title, url, manual, version, author, published ...)
 */
$FunctionList['recent_pages'] = array( 'name' => 'recent_pages',
                                       'operation_types' => array( 'read' ),
                                       'call_method' => array( 'class' => 'expDocRecent',
                                                               'method' => 'latest' ),
                                       'parameter_type' => 'standard',
                                       'parameters' => array( array( 'name' => 'mode',
                                                                     'type' => 'string',
                                                                     'required' => false,
                                                                     'default' => 'new' ),
                                                              array( 'name' => 'limit',
                                                                     'type' => 'integer',
                                                                     'required' => false,
                                                                     'default' => 8 ) ) );
