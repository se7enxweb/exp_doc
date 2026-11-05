<?php
/**
 * doc/recent: the recent changes of the documentation (expDocRecent), in the site's design (design:doc/recent.tpl),
 * and doc/new: the pages added, newest first by their first publication on this site;
 * or as an Atom feed with (feed)/atom. The filter form posts; the view answers with a redirect to the same list with
 * the filters as view parameters, so every list has an address of its own and no query string.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
// doc/new is this view in the mode new: the pages newest first by their first publication ([RecentSettings] NewPath)
$mode = $Module->currentView() === 'new' ? 'new' : 'changed';
$pathSetting = $mode === 'new' ? 'NewPath' : 'Path';
// the help center's Markdown pages are a choice of the recent changes only: the help index knows when a file last
// changed, not when it was added
$withHelp = $mode !== 'new';
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
    return $Module->redirectTo( '/' . expDocRecent::uri( expDocRecent::filters( $posted, $withHelp ), $extra, $pathSetting ) );
}

$view = array();
foreach ( array( 'Manual' => 'manual', 'Version' => 'version', 'Class' => 'class', 'Contributor' => 'contributor', 'Range' => 'range' ) as $name => $key )
{
    if ( isset( $Params[$name] ) && $Params[$name] !== false )
    {
        $view[$key] = (string)$Params[$name];
    }
}
$filters = expDocRecent::filters( $view, $withHelp );
$limit = isset( $Params['Limit'] ) && in_array( (int)$Params['Limit'], $limits, true ) ? (int)$Params['Limit'] : $defaultLimit;
$offset = isset( $Params['Offset'] ) && ctype_digit( (string)$Params['Offset'] ) ? (int)$Params['Offset'] : 0;
$title = $mode === 'new' ? ezpI18n::tr( 'design/exp_doc', 'Recently added' ) : ezpI18n::tr( 'design/exp_doc', 'Recent changes' );
$host = 'https://' . eZSys::hostname();

if ( isset( $Params['Feed'] ) && $Params['Feed'] === 'atom' )
{
    $list = expDocRecent::fetch( $filters, 0, (int)$ini->variable( 'RecentSettings', 'FeedLimit' ), $mode );
    $self = expDocRecent::uri( $filters, array( 'feed' => 'atom' ), $pathSetting );
    $page = expDocRecent::uri( $filters, array(), $pathSetting );
    eZURI::transformURI( $self );
    eZURI::transformURI( $page );
    header( 'Content-Type: application/atom+xml; charset=utf-8' );
    echo expDocRecent::atom( $list['items'], $ini->variable( 'ModernSettings', 'SiteName' ) . ': ' . $title, $host . $self, $host . $page );
    eZExecution::cleanExit();
}

$list = expDocRecent::fetch( $filters, $offset, $limit, $mode );
$feed = expDocRecent::uri( $filters, array( 'feed' => 'atom' ), $pathSetting );
$tpl = eZTemplate::factory();
$tpl->setVariable( 'groups', expDocRecent::byDay( $mode === 'new' ? array_map( function ( $item ) { return array_merge( $item, array( 'day' => $item['published_day'] ) ); }, $list['items'] ) : $list['items'] ) );
$tpl->setVariable( 'count', $list['count'] );
$tpl->setVariable( 'offset', $offset );
$tpl->setVariable( 'limit', $limit );
$tpl->setVariable( 'limits', $limits );
$tpl->setVariable( 'default_limit', $defaultLimit );
$tpl->setVariable( 'filters', $filters );
$tpl->setVariable( 'options', expDocRecent::options( $withHelp ) );
$tpl->setVariable( 'page_uri', expDocRecent::uri( $filters, $limit !== $defaultLimit ? array( 'limit' => $limit ) : array(), $pathSetting ) );
$tpl->setVariable( 'base_uri', expDocRecent::uri( array(), array(), $pathSetting ) );
$tpl->setVariable( 'mode', $mode );
$tpl->setVariable( 'changes_uri', expDocRecent::uri( array() ) );
$tpl->setVariable( 'new_uri', expDocRecent::uri( array(), array(), 'NewPath' ) );
$tpl->setVariable( 'comments_uri', expDocRecent::uri( array(), array(), 'CommentsPath' ) );
$tpl->setVariable( 'feed_uri', $feed );
$tpl->setVariable( 'view_parameters', array( 'offset' => $offset ) );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:doc/recent.tpl' );
$Result['path'] = array( array( 'text' => $title, 'url' => false ) );
$Result['title_path'] = $Result['path'];
$Result['content_info'] = array( 'persistent_variable' => array( 'doc_feed' => $feed, 'doc_feed_title' => $title ) );
