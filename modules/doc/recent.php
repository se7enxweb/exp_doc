<?php
/**
 * doc/recent: the recent changes of the documentation (expDocRecent), in the site's design (design:doc/recent.tpl),
 * or as an Atom feed with (feed)/atom. The filter form posts; the view answers with a redirect to the same list with
 * the filters as view parameters, so every list has an address of its own and no query string.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
$ini = eZINI::instance( 'exp_doc.ini' );
$limits = array_map( 'intval', (array)$ini->variable( 'RecentSettings', 'Limits' ) );
$defaultLimit = (int)$ini->variable( 'RecentSettings', 'DefaultLimit' );

if ( $Module->isCurrentAction( 'Filter' ) )
{
    $posted = array();
    foreach ( array( 'Manual' => 'manual', 'Version' => 'version', 'Class' => 'class', 'Contributor' => 'contributor', 'Range' => 'range' ) as $name => $key )
    {
        if ( $Module->hasActionParameter( $name ) )
        {
            $posted[$key] = (string)$Module->actionParameter( $name );
        }
    }
    $extra = array();
    if ( $Module->hasActionParameter( 'Limit' ) && in_array( (int)$Module->actionParameter( 'Limit' ), $limits, true )
         && (int)$Module->actionParameter( 'Limit' ) !== $defaultLimit )
    {
        $extra['limit'] = (int)$Module->actionParameter( 'Limit' );
    }
    return $Module->redirectTo( '/' . expDocRecent::uri( expDocRecent::filters( $posted ), $extra ) );
}

$view = array();
foreach ( array( 'Manual' => 'manual', 'Version' => 'version', 'Class' => 'class', 'Contributor' => 'contributor', 'Range' => 'range' ) as $name => $key )
{
    if ( isset( $Params[$name] ) && $Params[$name] !== false )
    {
        $view[$key] = (string)$Params[$name];
    }
}
$filters = expDocRecent::filters( $view );
$limit = isset( $Params['Limit'] ) && in_array( (int)$Params['Limit'], $limits, true ) ? (int)$Params['Limit'] : $defaultLimit;
$offset = isset( $Params['Offset'] ) && ctype_digit( (string)$Params['Offset'] ) ? (int)$Params['Offset'] : 0;
$title = ezpI18n::tr( 'design/exp_doc', 'Recent changes' );
$host = 'https://' . eZSys::hostname();

if ( isset( $Params['Feed'] ) && $Params['Feed'] === 'atom' )
{
    $list = expDocRecent::fetch( $filters, 0, (int)$ini->variable( 'RecentSettings', 'FeedLimit' ) );
    $self = expDocRecent::uri( $filters, array( 'feed' => 'atom' ) );
    $page = expDocRecent::uri( $filters );
    eZURI::transformURI( $self );
    eZURI::transformURI( $page );
    header( 'Content-Type: application/atom+xml; charset=utf-8' );
    echo expDocRecent::atom( $list['items'], $ini->variable( 'ModernSettings', 'SiteName' ) . ': ' . $title, $host . $self, $host . $page );
    eZExecution::cleanExit();
}

$list = expDocRecent::fetch( $filters, $offset, $limit );
$feed = expDocRecent::uri( $filters, array( 'feed' => 'atom' ) );
$tpl = eZTemplate::factory();
$tpl->setVariable( 'groups', expDocRecent::byDay( $list['items'] ) );
$tpl->setVariable( 'count', $list['count'] );
$tpl->setVariable( 'offset', $offset );
$tpl->setVariable( 'limit', $limit );
$tpl->setVariable( 'limits', $limits );
$tpl->setVariable( 'default_limit', $defaultLimit );
$tpl->setVariable( 'filters', $filters );
$tpl->setVariable( 'options', expDocRecent::options() );
$tpl->setVariable( 'page_uri', expDocRecent::uri( $filters, $limit !== $defaultLimit ? array( 'limit' => $limit ) : array() ) );
$tpl->setVariable( 'base_uri', expDocRecent::uri( array() ) );
$tpl->setVariable( 'feed_uri', $feed );
$tpl->setVariable( 'view_parameters', array( 'offset' => $offset ) );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:doc/recent.tpl' );
$Result['path'] = array( array( 'text' => $title, 'url' => false ) );
$Result['title_path'] = $Result['path'];
$Result['content_info'] = array( 'persistent_variable' => array( 'doc_feed' => $feed, 'doc_feed_title' => $title ) );
