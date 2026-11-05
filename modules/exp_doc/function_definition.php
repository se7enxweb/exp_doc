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
                                                                      'default' => false ),
                                                               array( 'name' => 'offset',
                                                                      'type' => 'integer',
                                                                      'required' => false,
                                                                      'default' => 0 ) ) );

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
 *   fetch( 'exp_doc', 'product_landing', hash( 'node_id', <node id> ) )
 *       the landing page of a product's container (the node at a path of [ModernSettings] ProductList[]): the product,
 *       the product it belongs to, its links, sections, related sections, recently changed pages and the family
 *       (expDocFetch::productLanding()); false for every other node
 *   fetch( 'exp_doc', 'is_product', hash( 'node_id', <node id> ) )
 *       whether the node is a product's container (no other query than the node's own)
 */
$FunctionList['product_landing'] = array( 'name' => 'product_landing',
                                          'operation_types' => array( 'read' ),
                                          'call_method' => array( 'class' => 'expDocFetch',
                                                                  'method' => 'productLanding' ),
                                          'parameter_type' => 'standard',
                                          'parameters' => array( array( 'name' => 'node_id',
                                                                        'type' => 'integer',
                                                                        'required' => true ) ) );
$FunctionList['is_product'] = array( 'name' => 'is_product',
                                     'operation_types' => array( 'read' ),
                                     'call_method' => array( 'class' => 'expDocFetch',
                                                             'method' => 'isProduct' ),
                                     'parameter_type' => 'standard',
                                     'parameters' => array( array( 'name' => 'node_id',
                                                                   'type' => 'integer',
                                                                   'required' => true ) ) );

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

/*
 *   fetch( 'exp_doc', 'comment_children', hash( 'node_id', <page or comment node id>, 'class', <comment class> ) )
 *       the comments of that class directly below the node, in their stored order (priority, then publication): one
 *       level of a thread; the templates ask again for each comment's own replies
 */
$FunctionList['comment_children'] = array( 'name' => 'comment_children',
                                           'operation_types' => array( 'read' ),
                                           'call_method' => array( 'class' => 'expDocComment',
                                                                   'method' => 'children' ),
                                           'parameter_type' => 'standard',
                                           'parameters' => array( array( 'name' => 'node_id',
                                                                         'type' => 'integer',
                                                                         'required' => true ),
                                                                  array( 'name' => 'class',
                                                                         'type' => 'string',
                                                                         'required' => true ) ) );

/*
 *   fetch( 'exp_doc', 'commenter_list' )
 *       the people of the Contributors page whose only role is the author of historical comments, most comments
 *       first: the entries of contributor_list with comments (how many) and last_comment (the newest one's date)
 */
$FunctionList['commenter_list'] = array( 'name' => 'commenter_list',
                                         'operation_types' => array( 'read' ),
                                         'call_method' => array( 'class' => 'expDocFetch',
                                                                 'method' => 'commenterList' ),
                                         'parameter_type' => 'standard',
                                         'parameters' => array() );

/*
 *   fetch( 'exp_doc', 'contributor_pages', hash( 'object_id', <contributor object id>, 'offset', 0, 'limit', 24 ) )
 *       the pages that name a contributor, newest change first: hash( nodes, count ), only visible main nodes the
 *       reader may open, without the classes the menus leave out (historical copies, comments ...)
 */
$FunctionList['contributor_pages'] = array( 'name' => 'contributor_pages',
                                            'operation_types' => array( 'read' ),
                                            'call_method' => array( 'class' => 'expDocFetch',
                                                                    'method' => 'contributorPages' ),
                                            'parameter_type' => 'standard',
                                            'parameters' => array( array( 'name' => 'object_id', 'type' => 'integer', 'required' => true ),
                                                                   array( 'name' => 'offset', 'type' => 'integer', 'required' => false, 'default' => 0 ),
                                                                   array( 'name' => 'limit', 'type' => 'integer', 'required' => false, 'default' => 24 ) ) );

/*
 *   fetch( 'exp_doc', 'recent_ratings', hash( 'limit', 8 ) )
 *       the newest ratings of pages a reader may open, each as a hash: node, stars (given), time, average and count
 *       (the page's now); never who rated
 */
$FunctionList['recent_ratings'] = array( 'name' => 'recent_ratings',
                                         'operation_types' => array( 'read' ),
                                         'call_method' => array( 'class' => 'expDocRating',
                                                                 'method' => 'latest' ),
                                         'parameter_type' => 'standard',
                                         'parameters' => array( array( 'name' => 'limit', 'type' => 'integer', 'required' => false, 'default' => 8 ) ) );

/*
 *   fetch( 'exp_doc', 'help_support' )
 *       the help center's "Support Exponential" block for the front page, as the help dashboard has it (the kernel's
 *       exphelp.ini [SupportSettings] and [SupportOrganization_<id>]), or false; drawn by exphelp/parts/support.tpl
 *   fetch( 'exp_doc', 'help_report' )
 *       the help center's "Found an error?" block: hash( 'url' (the reporting guide), 'trackers' (exphelp.ini)), or
 *       false; drawn by exphelp/parts/dashboard_report.tpl
 */
$FunctionList['help_support'] = array( 'name' => 'help_support',
                                       'operation_types' => array( 'read' ),
                                       'call_method' => array( 'class' => 'expDocFetch',
                                                               'method' => 'helpSupport' ),
                                       'parameter_type' => 'standard',
                                       'parameters' => array() );
$FunctionList['help_report'] = array( 'name' => 'help_report',
                                      'operation_types' => array( 'read' ),
                                      'call_method' => array( 'class' => 'expDocFetch',
                                                              'method' => 'helpReport' ),
                                      'parameter_type' => 'standard',
                                      'parameters' => array() );

/*
 *   fetch( 'exp_doc', 'help_recent_changes', hash( 'limit', 8 ) )
 *       the help's Markdown pages changed last (the developers' help page's "Recently updated", in the reader's help
 *       language), each a hash: id, title, subject, time, url (the help viewer, keeping /(lang)/<key>); empty when the
 *       help is off
 *   fetch( 'exp_doc', 'help_commits', hash( 'limit', 8 ) )
 *       the latest commits of the Exponential repository without merges (the kernel's expHelpCommitFeed, from its
 *       cache): hash( 'commits', 'fetched', 'stale', 'error', 'history', 'more' (the developers' page's log)), or false
 */
$FunctionList['help_recent_changes'] = array( 'name' => 'help_recent_changes',
                                              'operation_types' => array( 'read' ),
                                              'call_method' => array( 'class' => 'expDocFetch',
                                                                      'method' => 'helpRecentChanges' ),
                                              'parameter_type' => 'standard',
                                              'parameters' => array( array( 'name' => 'limit', 'type' => 'integer', 'required' => false, 'default' => 8 ) ) );
$FunctionList['help_commits'] = array( 'name' => 'help_commits',
                                       'operation_types' => array( 'read' ),
                                       'call_method' => array( 'class' => 'expDocFetch',
                                                               'method' => 'helpCommits' ),
                                       'parameter_type' => 'standard',
                                       'parameters' => array( array( 'name' => 'limit', 'type' => 'integer', 'required' => false, 'default' => 8 ) ) );

/*
 *   fetch( 'exp_doc', 'forum_activity' )
 *       the newest topics and replies of the Exponential Share forums (expDocForumFeed: the forums' RSS feed, read by
 *       the server with the kernel commit feed's timeout and cache; exp_doc.ini [ModernSettings] ForumFeedURL,
 *       ForumFeedLimit, ForumFeedExcludeTitles[], ForumURL): hash( 'items' (each: id, title, reply, author, time,
 *       url), 'fetched', 'stale', 'error', 'more' (the forums' address) ), or false when switched off or the kernel
 *       has no feed reader. A limit overrides ForumFeedLimit.
 */
$FunctionList['forum_activity'] = array( 'name' => 'forum_activity',
                                         'operation_types' => array( 'read' ),
                                         'call_method' => array( 'class' => 'expDocFetch',
                                                                 'method' => 'forumActivity' ),
                                         'parameter_type' => 'standard',
                                         'parameters' => array( array( 'name' => 'limit', 'type' => 'integer', 'required' => false, 'default' => false ) ) );

/*
 *   fetch( 'exp_doc', 'confluence_context', hash( 'node_id', <node id> ) )
 *       the Atlassian frame of a page from the former documentation center's Confluence spaces in the Classic design:
 *       its space (node, key, name, home page), its title without the static suffix, its breadcrumbs, the space's
 *       page tree and its attachments (expDocFetch::confluenceContext()); false for every other node
 */
$FunctionList['confluence_context'] = array( 'name' => 'confluence_context',
                                             'operation_types' => array( 'read' ),
                                             'call_method' => array( 'class' => 'expDocFetch',
                                                                     'method' => 'confluenceContext' ),
                                             'parameter_type' => 'standard',
                                             'parameters' => array( array( 'name' => 'node_id',
                                                                           'type' => 'integer',
                                                                           'required' => true ) ) );
