<?php
/**
 * The module doc: views of the documentation site that belong to no node.
 *
 *   doc/recent   the recent changes of every page, newest first, by day; filters, paging and the Atom feed as view
 *                parameters: (manual)/<node id> (version)/<node id> (class)/<identifier> (contributor)/<object id>
 *                (range)/24h|7d|30d|all (offset)/<n> (limit)/<n> (feed)/atom. Reached at its URL alias
 *                (exp_doc.ini [RecentSettings] Path, "recent"); the policy doc/read (the Doc reader role).
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

$FunctionList = array();
$FunctionList['read'] = array();
