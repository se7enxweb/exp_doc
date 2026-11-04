<?php
/**
 * exp_doc/help/<page id>: the help center bridge's old address. The kernel's help center now runs on the
 * documentation site for every reader (exphelp/read in the Doc reader role, the doc designs' exphelp templates), so
 * this view answers with a permanent redirect to the same page in exphelp/viewer (exphelp/dashboard without an id).
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
$id = class_exists( 'expHelp' ) ? expHelp::requestedId( $Params ) : '';
$target = $id === '' ? 'exphelp/dashboard' : 'exphelp/viewer/' . implode( '/', array_map( 'rawurlencode', explode( '/', $id ) ) );
eZURI::transformURI( $target );
header( 'Location: ' . $target, true, 301 );
eZExecution::cleanExit();
