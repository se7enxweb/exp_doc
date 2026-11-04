<?php
/**
 * exp_doc/help/<page id>: a page of the installation's help center, rendered live from its Markdown (or text) file
 * by the kernel's renderer, inside the site's design (design:exp_doc/help.tpl). Links to other help pages and images
 * stay on this site (expDocHelpBridge); a page that is not in the help center is a 404. Without an id: the help
 * center's start page (README.md).
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
if ( !class_exists( 'expHelpDocumentIndex' ) || !expHelp::isEnabled() )
{
    return $Module->handleError( eZError::KERNEL_MODULE_NOT_FOUND, 'kernel' );
}

$id = expHelp::requestedId( $Params );
if ( $id === '' )
{
    $id = 'README.md';
}
$page = expDocHelpBridge::page( $id );
if ( $page === null )
{
    return $Module->handleError( eZError::KERNEL_NOT_FOUND, 'kernel' );
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'help_page', $page );
$Result = array();
$Result['content'] = $tpl->fetch( 'design:exp_doc/help.tpl' );
$Result['path'] = $page['path'];
$Result['title_path'] = $page['path'];
