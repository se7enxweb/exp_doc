<?php
/**
 * exp_doc/helpfile/<file id>: an image of a help center page shown through exp_doc/help, when the help center
 * allows it (a git-tracked image of a documentation folder); anything else is a 404.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
$id = expHelp::requestedId( $Params );
$file = $id === '' || !class_exists( 'expHelpDocumentIndex' ) ? null : expHelpDocumentIndex::instance()->asset( $id );
$types = array( 'png' => 'image/png', 'jpg' => 'image/jpeg', 'jpeg' => 'image/jpeg', 'gif' => 'image/gif', 'webp' => 'image/webp' );
$suffix = strtolower( pathinfo( (string)$file, PATHINFO_EXTENSION ) );
if ( $file === null || !isset( $types[$suffix] ) || !is_file( $file ) )
{
    return $Module->handleError( eZError::KERNEL_NOT_FOUND, 'kernel' );
}
header( 'Cache-Control: public, max-age=86400' );
header( 'X-Content-Type-Options: nosniff' );
header( "Content-Security-Policy: default-src 'none'" );
header( 'Content-Type: ' . $types[$suffix] );
header( 'Content-Length: ' . filesize( $file ) );
readfile( $file );
eZExecution::cleanExit();
