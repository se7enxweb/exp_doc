<?php
/**
 * doc/ratings: the newest ratings of the documentation's pages (expDocRating), in the site's design
 * (design:doc/ratings.tpl), or as an Atom feed with (feed)/atom. Who rated is never shown. Filters, paging and the
 * feed are view parameters; the filter form posts and is answered with a redirect to the list's own address.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];
$ini = eZINI::instance( 'exp_doc.ini' );
$limits = array_map( 'intval', (array)$ini->variable( 'RecentSettings', 'Limits' ) );
$defaultLimit = (int)$ini->variable( 'RecentSettings', 'DefaultLimit' );
$keys = array( 'Manual' => 'manual', 'Version' => 'version', 'Range' => 'range', 'Stars' => 'stars' );

if ( $Module->isCurrentAction( 'Filter' ) )
{
    $posted = array();
    foreach ( $keys as $name => $key )
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
    return $Module->redirectTo( '/' . expDocRecent::uri( expDocRating::filters( $posted ), $extra, 'RatingsPath' ) );
}

$view = array();
foreach ( $keys as $name => $key )
{
    if ( isset( $Params[$name] ) && $Params[$name] !== false )
    {
        $view[$key] = (string)$Params[$name];
    }
}
$filters = expDocRating::filters( $view );
$limit = isset( $Params['Limit'] ) && in_array( (int)$Params['Limit'], $limits, true ) ? (int)$Params['Limit'] : $defaultLimit;
$offset = isset( $Params['Offset'] ) && ctype_digit( (string)$Params['Offset'] ) ? (int)$Params['Offset'] : 0;
$title = ezpI18n::tr( 'design/exp_doc', 'Recent ratings' );
$host = 'https://' . eZSys::hostname();

if ( isset( $Params['Feed'] ) && $Params['Feed'] === 'atom' )
{
    $list = expDocRating::recent( $filters, 0, (int)$ini->variable( 'RecentSettings', 'FeedLimit' ) );
    $esc = function ( $text ) { return htmlspecialchars( (string)$text, ENT_XML1 | ENT_QUOTES, 'UTF-8' ); };
    $self = expDocRecent::uri( $filters, array( 'feed' => 'atom' ), 'RatingsPath' );
    $page = expDocRecent::uri( $filters, array(), 'RatingsPath' );
    eZURI::transformURI( $self );
    eZURI::transformURI( $page );
    $name = $ini->variable( 'ModernSettings', 'SiteName' ) . ': ' . $title;
    $xml = '<?xml version="1.0" encoding="utf-8"?>' . "\n" . '<feed xmlns="http://www.w3.org/2005/Atom">' . "\n"
         . '  <title>' . $esc( $name ) . "</title>\n  <id>" . $esc( $host . $self ) . "</id>\n"
         . '  <link rel="self" type="application/atom+xml" href="' . $esc( $host . $self ) . '"/>' . "\n"
         . '  <link rel="alternate" type="text/html" href="' . $esc( $host . $page ) . '"/>' . "\n"
         . '  <updated>' . date( DATE_ATOM, $list['items'] ? $list['items'][0]['time'] : time() ) . "</updated>\n"
         . '  <author><name>' . $esc( $name ) . "</name></author>\n"
         . '  <rights>' . $esc( expDocRecent::rights() ) . "</rights>\n";
    foreach ( $list['items'] as $item )
    {
        $url = $item['node']->attribute( 'url_alias' );
        eZURI::transformURI( $url );
        $url = $host . $url;
        $text = ezpI18n::tr( 'design/exp_doc', 'Rated %stars of 5; the page now has %average of 5 from %count ratings', null,
                             array( '%stars' => $item['stars'], '%average' => $item['average'], '%count' => $item['count'] ) );
        $xml .= "  <entry>\n    <title>" . $esc( $item['node']->attribute( 'name' ) ) . "</title>\n"
              . '    <id>' . $esc( $url . '#rating-' . $item['time'] . '-' . $item['stars'] ) . "</id>\n"
              . '    <link rel="alternate" type="text/html" href="' . $esc( $url ) . '"/>' . "\n"
              . '    <updated>' . date( DATE_ATOM, $item['time'] ) . "</updated>\n"
              . '    <summary>' . $esc( $text ) . "</summary>\n  </entry>\n";
    }
    header( 'Content-Type: application/atom+xml; charset=utf-8' );
    echo $xml . "</feed>\n";
    eZExecution::cleanExit();
}

$list = expDocRating::recent( $filters, $offset, $limit );
$feed = expDocRecent::uri( $filters, array( 'feed' => 'atom' ), 'RatingsPath' );
$tpl = eZTemplate::factory();
$tpl->setVariable( 'groups', expDocRecent::byDay( $list['items'] ) );
$tpl->setVariable( 'count', $list['count'] );
$tpl->setVariable( 'offset', $offset );
$tpl->setVariable( 'limit', $limit );
$tpl->setVariable( 'limits', $limits );
$tpl->setVariable( 'filters', $filters );
$tpl->setVariable( 'options', expDocRecent::options() );
$tpl->setVariable( 'page_uri', expDocRecent::uri( $filters, $limit !== $defaultLimit ? array( 'limit' => $limit ) : array(), 'RatingsPath' ) );
$tpl->setVariable( 'base_uri', expDocRecent::uri( array(), array(), 'RatingsPath' ) );
$tpl->setVariable( 'pages_uri', expDocRecent::uri( array() ) );
$tpl->setVariable( 'feed_uri', $feed );
$tpl->setVariable( 'view_parameters', array( 'offset' => $offset ) );

$Result = array();
$Result['content'] = $tpl->fetch( 'design:doc/ratings.tpl' );
$Result['path'] = array( array( 'text' => ezpI18n::tr( 'design/exp_doc', 'Recent changes' ), 'url' => expDocRecent::uri( array() ) ),
                         array( 'text' => $title, 'url' => false ) );
$Result['title_path'] = $Result['path'];
$Result['content_info'] = array( 'persistent_variable' => array( 'doc_feed' => $feed, 'doc_feed_title' => $title ) );
