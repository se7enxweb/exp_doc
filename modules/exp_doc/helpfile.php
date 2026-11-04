<?php
/**
 * exp_doc/helpfile/<file id>: the old address of a help image; a permanent redirect to the help center's own
 * exphelp/asset view.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
$id = class_exists( 'expHelp' ) ? expHelp::requestedId( $Params ) : '';
$target = 'exphelp/asset/' . implode( '/', array_map( 'rawurlencode', explode( '/', $id ) ) );
eZURI::transformURI( $target );
header( 'Location: ' . $target, true, 301 );
eZExecution::cleanExit();
