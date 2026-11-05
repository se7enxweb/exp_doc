<?php
/**
 * The module doc: views of the documentation site that belong to no node.
 *
 *   doc/recent   the recent changes of every page, newest first, by day; filters, paging and the Atom feed as view
 *                parameters: (manual)/<node id>|help (help: the help center's Markdown pages; without a manual, version,
 *                kind or contributor they are merged in by date) (version)/<node id> (class)/<identifier> (contributor)/<object id>
 *                (range)/24h|7d|30d|all (offset)/<n> (limit)/<n> (feed)/atom. Reached at its URL alias
 *                (exp_doc.ini [RecentSettings] Path, "recent"); the policy doc/read (the Doc reader role).
 *   doc/new      the pages added, newest first by their first publication on this site (the object's published date);
 *                the same filters, paging and feed as doc/recent but content pages only (the help index knows when a
 *                Markdown file last changed, not when it was added), at its URL alias [RecentSettings] NewPath, "recent/new".
 *   doc/comments the newest approved comments (never a held one), newest first: (manual) (version) (range) as for
 *                doc/recent, (type)/readers|all (all: the historical comments too), (offset) (limit), (feed)/atom; at its
 *                URL alias [RecentSettings] CommentsPath, "recent/comments".
 *   doc/ratings  the newest ratings of pages (ezstarrating_data, never who rated), newest first: (manual) (version)
 *                (range) as for doc/recent, (stars)/<least stars>, (offset) (limit), (feed)/atom; at its URL alias
 *                [RecentSettings] RatingsPath, "recent/ratings".
 *   doc/comment  POST only: a reader's comment on a page or a reply to a comment (classes/expdoccomment.php); held
 *                for moderation by the review hold, then back to the page with (comment)/held. The policy doc/read, and
 *                content/create of the comment class where it is stored.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = array( 'name' => 'Documentation' );

$ViewList = array();
$ViewList['recent'] = array( 'script' => 'recent.php',
                             'functions' => array( 'read' ),
                             'params' => array(),
                             'unordered_params' => array( 'offset' => 'Offset', 'limit' => 'Limit', 'manual' => 'Manual',
                                                          'version' => 'Version', 'class' => 'Class',
                                                          'contributor' => 'Contributor', 'range' => 'Range', 'feed' => 'Feed' ),
                             'single_post_actions' => array( 'FilterButton' => 'Filter' ),
                             'post_action_parameters' => array( 'Filter' => array( 'Manual' => 'Manual', 'Version' => 'Version',
                                                                                   'Class' => 'Class', 'Contributor' => 'Contributor',
                                                                                   'Range' => 'Range', 'Limit' => 'Limit' ) ) );
$ViewList['new'] = $ViewList['recent'];
$ViewList['comments'] = array( 'script' => 'comments.php',
                               'functions' => array( 'read' ),
                               'params' => array(),
                               'unordered_params' => array( 'offset' => 'Offset', 'limit' => 'Limit', 'manual' => 'Manual',
                                                            'version' => 'Version', 'range' => 'Range', 'type' => 'Type', 'feed' => 'Feed' ),
                               'single_post_actions' => array( 'FilterButton' => 'Filter' ),
                               'post_action_parameters' => array( 'Filter' => array( 'Manual' => 'Manual', 'Version' => 'Version',
                                                                                    'Range' => 'Range', 'Type' => 'Type', 'Limit' => 'Limit' ) ) );
$ViewList['ratings'] = array( 'script' => 'ratings.php',
                              'functions' => array( 'read' ),
                              'params' => array(),
                              'unordered_params' => array( 'offset' => 'Offset', 'limit' => 'Limit', 'manual' => 'Manual',
                                                           'version' => 'Version', 'range' => 'Range', 'stars' => 'Stars', 'feed' => 'Feed' ),
                              'single_post_actions' => array( 'FilterButton' => 'Filter' ),
                              'post_action_parameters' => array( 'Filter' => array( 'Manual' => 'Manual', 'Version' => 'Version',
                                                                                   'Range' => 'Range', 'Stars' => 'Stars', 'Limit' => 'Limit' ) ) );
$ViewList['comment'] = array( 'script' => 'comment.php',
                              'functions' => array( 'read' ),
                              'params' => array(),
                              'single_post_actions' => array( 'CommentButton' => 'Comment' ),
                              'post_action_parameters' => array( 'Comment' => array( 'ParentNodeID' => 'ParentNodeID', 'Name' => 'CommentName',
                                                                                       'Email' => 'CommentEmail', 'Subject' => 'CommentSubject',
                                                                                       'Message' => 'CommentMessage', 'Website' => 'CommentWebsite' ) ) );

$FunctionList = array();
$FunctionList['read'] = array();
