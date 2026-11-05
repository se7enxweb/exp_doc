<?php
/**
 * Cronjob part of exp_doc (frequent, settings/cronjob.ini.append.php): reads the two outside feeds of the Modern
 * front page, the latest commits of Exponential (the kernel's expHelpCommitFeed, exphelp.ini [CommitFeedSettings]) and
 * the Share forums' newest posts (expDocForumFeed, exp_doc.ini [ModernSettings] ForumFeedURL), so their caches stay
 * younger than the cache time and a page view never waits for GitHub or the forums (a read takes 0.3 to 4 s, the
 * timeout). A feed that is off is skipped; a failed read keeps the last good list, as a read during a page view does.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

// @description Reads the front page's commit and forum feeds ahead of the page views

if ( !class_exists( 'expHelpCommitFeed' ) || !method_exists( 'expHelpCommitFeed', 'commits' ) )
{
    return;
}
$feeds = array();
if ( class_exists( 'expHelp' ) && expHelp::isEnabled() )
{
    $feeds['commits'] = new expHelpCommitFeed();
}
$forum = new expDocForumFeed();
$feeds['forum'] = $forum;
foreach ( $feeds as $name => $feed )
{
    $start = microtime( true );
    $cache = $forum->warm( $feed );
    $line = $cache === false
          ? "exp_doc feeds: $name not read (off, or another process reads it)"
          : sprintf( 'exp_doc feeds: %s read in %.1f s, %d entries%s', $name, microtime( true ) - $start, count( $cache['commits'] ),
                     $cache['error'] !== '' ? ', failed: ' . $cache['error'] . ' (the last good list is kept)' : '' );
    if ( isset( $cli ) && $cli instanceof eZCLI && empty( $isQuiet ) )
    {
        $cli->output( $line );
    }
    if ( $cache !== false && $cache['error'] !== '' )
    {
        eZDebug::writeWarning( $line, 'exp_doc_feeds' );
    }
}
