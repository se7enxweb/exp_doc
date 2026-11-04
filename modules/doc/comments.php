<?php
/**
 * doc/comments: the newest approved comments of the documentation (expDocComment::recent()), in the site's design
 * (design:doc/comments.tpl), or as an Atom feed with (feed)/atom. Filters, paging and the feed are view parameters;
 * the filter form posts and is answered with a redirect to the list's own address.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
$ini = eZINI::instance( 'exp_doc.ini' );
$limits = array_map( 'intval', (array)$ini->variable( 'RecentSettings', 'Limits' ) );
$defaultLimit = (int)$ini->variable( 'RecentSettings', 'DefaultLimit' );
$filtersOf = function ( array $raw )
{
    $filters = expDocRecent::filters( array_intersect_key( $raw, array( 'manual' => 1, 'version' => 1, 'range' => 1 ) ) );
    if ( isset( $raw['type'] ) && $raw['type'] === 'all' )
    {
        $filters['type'] = 'all';
    }
    return $filters;
};

if ( $Module->isCurrentAction( 'Filter' ) )
{
    $posted = array();
    foreach ( array( 'Manual' => 'manual', 'Version' => 'version', 'Range' => 'range', 'Type' => 'type' ) as $name => $key )
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
    return $Module->redirectTo( '/' . expDocRecent::uri( $filtersOf( $posted ), $extra, 'CommentsPath' ) );
}

$view = array();
foreach ( array( 'Manual' => 'manual', 'Version' => 'version', 'Range' => 'range', 'Type' => 'type' ) as $name => $key )
{
    if ( isset( $Params[$name] ) && $Params[$name] !== false )
    {
        $view[$key] = (string)$Params[$name];
    }
}
$filters = $filtersOf( $view );
$limit = isset( $Params['Limit'] ) && in_array( (int)$Params['Limit'], $limits, true ) ? (int)$Params['Limit'] : $defaultLimit;
$offset = isset( $Params['Offset'] ) && ctype_digit( (string)$Params['Offset'] ) ? (int)$Params['Offset'] : 0;
$title = ezpI18n::tr( 'design/exp_doc', 'Recent comments' );
$host = 'https://' . eZSys::hostname();

if ( isset( $Params['Feed'] ) && $Params['Feed'] === 'atom' )
{
    $list = expDocComment::recent( $filters, 0, (int)$ini->variable( 'RecentSettings', 'FeedLimit' ) );
    $esc = function ( $text ) { return htmlspecialchars( (string)$text, ENT_XML1 | ENT_QUOTES, 'UTF-8' ); };
    $self = expDocRecent::uri( $filters, array( 'feed' => 'atom' ), 'CommentsPath' );
    $page = expDocRecent::uri( $filters, array(), 'CommentsPath' );
    eZURI::transformURI( $self );
    eZURI::transformURI( $page );
    $name = $ini->variable( 'ModernSettings', 'SiteName' ) . ': ' . $title;
    $xml = '<?xml version="1.0" encoding="utf-8"?>' . "\n" . '<feed xmlns="http://www.w3.org/2005/Atom">' . "\n"
         . '  <title>' . $esc( $name ) . "</title>\n  <id>" . $esc( $host . $self ) . "</id>\n"
         . '  <link rel="self" type="application/atom+xml" href="' . $esc( $host . $self ) . '"/>' . "\n"
         . '  <link rel="alternate" type="text/html" href="' . $esc( $host . $page ) . '"/>' . "\n"
         . '  <updated>' . date( DATE_ATOM, $list['items'] ? max( 1, $list['items'][0]['date'] ) : time() ) . "</updated>\n"
         . '  <author><name>' . $esc( $name ) . "</name></author>\n"
         . '  <rights>' . $esc( expDocRecent::rights() ) . "</rights>\n";
    foreach ( $list['items'] as $item )
    {
        $url = $item['page'] ? $item['page']->attribute( 'url_alias' ) : '';
        eZURI::transformURI( $url );
        $url = $host . $url . '#' . $item['anchor'];
        $xml .= "  <entry>\n    <title>" . $esc( $item['subject'] ) . "</title>\n    <id>" . $esc( $url ) . "</id>\n"
              . '    <link rel="alternate" type="text/html" href="' . $esc( $url ) . '"/>' . "\n"
              . '    <updated>' . date( DATE_ATOM, $item['date'] ?: time() ) . "</updated>\n"
              . ( $item['name'] !== '' ? '    <author><name>' . $esc( $item['name'] ) . "</name></author>\n" : '' )
              . '    <summary>' . $esc( ( $item['page'] ? $item['page']->attribute( 'name' ) . ': ' : '' ) . $item['excerpt'] ) . "</summary>\n"
              . "  </entry>\n";
    }
    header( 'Content-Type: application/atom+xml; charset=utf-8' );
    echo $xml . "</feed>\n";
    eZExecution::cleanExit();
}

$list = expDocComment::recent( $filters, $offset, $limit );
$feed = expDocRecent::uri( $filters, array( 'feed' => 'atom' ), 'CommentsPath' );
$tpl = eZTemplate::factory();
$tpl->setVariable( 'groups', expDocRecent::byDay( array_map( function ( $item )
{
    return $item + array( 'day' => date( 'Y-m-d', $item['date'] ?: 0 ) );
}, $list['items'] ) ) );
$tpl->setVariable( 'count', $list['count'] );
$tpl->setVariable( 'offset', $offset );
$tpl->setVariable( 'limit', $limit );
$tpl->setVariable( 'limits', $limits );
$tpl->setVariable( 'filters', $filters );
$tpl->setVariable( 'options', expDocRecent::options() );
$tpl->setVariable( 'page_uri', expDocRecent::uri( $filters, $limit !== $defaultLimit ? array( 'limit' => $limit ) : array(), 'CommentsPath' ) );
$tpl->setVariable( 'base_uri', expDocRecent::uri( array(), array(), 'CommentsPath' ) );
$tpl->setVariable( 'pages_uri', expDocRecent::uri( array() ) );
$tpl->setVariable( 'feed_uri', $feed );
$tpl->setVariable( 'view_parameters', array( 'offset' => $offset ) );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:doc/comments.tpl' );
$Result['path'] = array( array( 'text' => ezpI18n::tr( 'design/exp_doc', 'Recent changes' ), 'url' => expDocRecent::uri( array() ) ),
                         array( 'text' => $title, 'url' => false ) );
$Result['title_path'] = $Result['path'];
$Result['content_info'] = array( 'persistent_variable' => array( 'doc_feed' => $feed, 'doc_feed_title' => $title ) );
