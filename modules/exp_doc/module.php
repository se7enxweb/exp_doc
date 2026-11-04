<?php
/**
 * The module exp_doc: the help center bridge of the Modern design and the template fetch functions
 * (function_definition.php).
 *
 *   exp_doc/help/<page id>      a page of the installation's help center (the kernel's doc/ Markdown and the
 *                               active extensions' doc/ folders), rendered live from its file in the site's design
 *   exp_doc/helpfile/<file id>  an image of those pages
 *
 * Both views are public (site.ini [RoleSettings] PolicyOmitList[] in this extension's settings): the help center's
 * pages are the project's published documentation.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = array( 'name' => 'Exponential Documentation' );

$ViewList = array();
$ViewList['help'] = array( 'script' => 'help.php', 'params' => array() );
$ViewList['helpfile'] = array( 'script' => 'helpfile.php', 'params' => array() );

$FunctionList = array();
