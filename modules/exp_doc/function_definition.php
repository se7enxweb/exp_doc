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
