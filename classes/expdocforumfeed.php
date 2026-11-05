<?php
/**
 * File containing the expDocForumFeed class.
 *
 * The latest topics and replies of the Exponential Share forums for the Modern front page's "Recent forum activity"
 * (parts/doc_landing.tpl, fetch exp_doc/forum_activity), read from the forums' RSS 2.0 feed ([ModernSettings]
 * ForumFeedURL in exp_doc.ini).
 *
 * Built on the kernel's commit feed reader (expHelpCommitFeed) rather than a copy of it: the same server side read with
 * a timeout, one read per cache time for the whole installation, a lock so only one process reads, a failed read
 * retried only after a while and the last good list kept and marked stale; the timeout, cache time and retry come from
 * the kernel's [CommitFeedSettings] in exphelp.ini, so both boxes behave alike. What differs is here:
 *
 * - its own cache, one per feed address (var/<site>/cache/exp_doc/feed-<hash of the address>/), never the commits';
 * - RSS 2.0 instead of Atom (parse()): item title, link, pubDate and author or dc:creator, as plain text (tags
 *   removed, entities decoded, lengths bounded) for the template to escape; nothing else of the feed is kept;
 * - each read replaces the list instead of adding to it (refresh()), so a post removed from the forums leaves the
 *   front page with the next read;
 * - links: only http(s) links on the feed's own host or its channel's host, always rebuilt on the feed's own host
 *   (the Share feed links share.se7enx.com, the configured address is share.exponential.earth); other items are left
 *   out;
 * - a title "Re: ..." becomes the topic's title with the reply flag; an author "Name ( http://... )" or
 *   "mail (Name)" keeps the name only, never an address;
 * - [ModernSettings] ForumFeedExcludeTitles[]: titles to leave out (shell patterns, case-insensitive, matched against
 *   the whole title without "Re: "), applied when shown so a change needs no new read.
 *
 * Needs the kernel's expHelpCommitFeed; expDocFetch::forumActivity() checks for it before loading this class.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocForumFeed extends expHelpCommitFeed
{
    const DEFAULT_FORUM_FEED = 'https://share.exponential.earth/rss/feed/all_forums';
    const DEFAULT_FORUM_URL = 'https://share.exponential.earth/forums';
    const MAX_ITEMS = 50;

    /**
     * @param array $options overrides (tests): feed, forum, exclude, limit and the kernel reader's options (ttl,
     *                       timeout, retry, cacheDir, enabled)
     * @param callable|null $fetcher function( string $url, int $timeout ): string|false
     */
    public function __construct( array $options = array(), $fetcher = null )
    {
        parent::__construct( $options + self::forumSettings( isset( $options['feed'] ) ? $options['feed'] : null ), $fetcher );
    }

    /**
     * exp_doc.ini [ModernSettings] ForumFeedURL, ForumURL, ForumFeedLimit and ForumFeedExcludeTitles[] over the kernel
     * reader's settings; an address that is not https is replaced by the default, an empty ForumFeedURL switches the
     * box off.
     *
     * @param string|null $feed the feed address when already known (tests), else from the settings
     * @return array
     */
    public static function forumSettings( $feed = null )
    {
        $ini = class_exists( 'eZINI' ) ? eZINI::instance( 'exp_doc.ini' ) : null;
        $get = function ( $name, $default ) use ( $ini ) {
            return $ini && $ini->hasVariable( 'ModernSettings', $name ) ? $ini->variable( 'ModernSettings', $name ) : $default;
        };
        $https = function ( $value, $default ) {
            return is_string( $value ) && preg_match( '#^https://[a-z0-9.-]+(?::[0-9]+)?/[^\s"\'<>]*$#i', $value ) ? $value : $default;
        };
        $configured = $feed !== null ? $feed : trim( (string)$get( 'ForumFeedURL', self::DEFAULT_FORUM_FEED ) );
        $feed = $https( $configured, self::DEFAULT_FORUM_FEED );
        $exclude = $get( 'ForumFeedExcludeTitles', array() );
        $cacheDir = class_exists( 'eZSys' ) ? eZSys::cacheDirectory() . '/exp_doc/feed-' . substr( sha1( $feed ), 0, 16 ) : null;
        return array(
            'enabled'  => $configured !== '',
            'feed'     => $feed,
            'forum'    => $https( trim( (string)$get( 'ForumURL', self::DEFAULT_FORUM_URL ) ), self::DEFAULT_FORUM_URL ),
            'limit'    => min( self::MAX_ITEMS, max( 1, (int)$get( 'ForumFeedLimit', 8 ) ) ),
            'exclude'  => array_values( array_filter( array_map( 'trim', is_array( $exclude ) ? $exclude : array() ), 'strlen' ) ),
            'max'      => self::MAX_ITEMS,
            'cacheDir' => $cacheDir,
        );
    }

    /**
     * The newest forum posts, reading the feed when the cache is older than the cache time.
     *
     * @param int|null $limit null: ForumFeedLimit
     * @param int|null $now
     * @return array array( 'items' => list of array( id, title, reply, author, time, url ), 'fetched', 'stale',
     *               'error', 'more' => the forums' address )
     */
    public function items( $limit = null, $now = null )
    {
        $result = $this->commits( $now );
        $limit = $limit === null ? $this->options['limit'] : min( self::MAX_ITEMS, max( 1, (int)$limit ) );
        $items = array();
        foreach ( $result['commits'] as $item )
        {
            if ( $this->excluded( $item['title'] ) )
                continue;
            $items[] = $item;
            if ( count( $items ) >= $limit )
                break;
        }
        return array( 'items' => $items, 'fetched' => $result['fetched'], 'stale' => $result['stale'],
                      'error' => $result['error'], 'more' => $this->options['forum'] );
    }

    /** Whether ForumFeedExcludeTitles[] leaves a title out (shell patterns, case-insensitive, the whole title) */
    public function excluded( $title )
    {
        foreach ( $this->options['exclude'] as $pattern )
            if ( fnmatch( $pattern, (string)$title, FNM_CASEFOLD ) )
                return true;
        return false;
    }

    /**
     * Reads a feed now, whatever the age of its cache, under the feed's lock (skipped while another process reads it):
     * the cronjob part exp_doc_feeds.php keeps the front page's boxes current this way, so a page view never waits for
     * a read (only a cache older than the cache time, when the cronjob has not run, is read during a page view). A
     * failed read keeps the last good list and is marked as before.
     *
     * @param expHelpCommitFeed|null $feed the feed to read (the kernel's commit feed), null: this one
     * @param int|null $now
     * @return array|false the cache after the read (commits, fetched, attempted, error), false when not read (off,
     *                     or the lock is held)
     */
    public function warm( ?expHelpCommitFeed $feed = null, $now = null )
    {
        $feed = $feed !== null ? $feed : $this;
        if ( !$feed->options['enabled'] || !$feed->lock() )
            return false;
        try
        {
            return $feed->refresh( $feed->readCache(), $now === null ? time() : (int)$now );
        }
        finally
        {
            $feed->unlock();
        }
    }

    /** Each read replaces the list; a failed read keeps the last good one */
    protected function refresh( array $cache, $now )
    {
        $kept = $cache['commits'];
        $cache['commits'] = array();
        $cache = parent::refresh( $cache, $now );
        if ( $cache['error'] !== '' )
        {
            $cache['commits'] = $kept;
            $this->writeCache( $cache );
        }
        return $cache;
    }

    /**
     * The posts of an RSS 2.0 feed, newest first, or null when it is not one. No network access while parsing
     * (LIBXML_NONET), no document type, no entities from outside.
     *
     * @param string $xml
     * @return array|null list of array( hash (of the link, for the reader's cache), id, title, reply, author, time, url )
     */
    public function parse( $xml )
    {
        if ( !is_string( $xml ) || strlen( $xml ) > 2097152 || stripos( $xml, '<!DOCTYPE' ) !== false )
            return null;
        $previous = libxml_use_internal_errors( true );
        $doc = new DOMDocument();
        $ok = $doc->loadXML( $xml, LIBXML_NONET | LIBXML_NOCDATA );
        libxml_clear_errors();
        libxml_use_internal_errors( $previous );
        if ( !$ok || !$doc->documentElement || $doc->documentElement->localName !== 'rss' )
            return null;
        $xpath = new DOMXPath( $doc );
        $xpath->registerNamespace( 'dc', 'http://purl.org/dc/elements/1.1/' );
        $feed = parse_url( $this->options['feed'] );
        $hosts = array( strtolower( $feed['host'] ) );
        $channel = parse_url( trim( (string)$xpath->evaluate( 'string(/rss/channel/link)' ) ) );
        if ( isset( $channel['host'] ) )
            $hosts[] = strtolower( $channel['host'] );
        $base = $feed['scheme'] . '://' . $feed['host'] . ( isset( $feed['port'] ) ? ':' . $feed['port'] : '' );
        $items = array();
        foreach ( $xpath->query( '/rss/channel/item' ) as $item )
        {
            $url = self::onHost( trim( (string)$xpath->evaluate( 'string(link)', $item ) ), $hosts, $base );
            if ( $url === null )
                continue;
            $title = self::plain( (string)$xpath->evaluate( 'string(title)', $item ), self::MAX_TITLE, true );
            $reply = (bool)preg_match( '/^re\s*:\s*/i', $title, $m );
            if ( $reply )
                $title = trim( substr( $title, strlen( $m[0] ) ) );
            $author = (string)$xpath->evaluate( 'string(dc:creator)', $item );
            if ( trim( $author ) === '' )
                $author = (string)$xpath->evaluate( 'string(author)', $item );
            $time = strtotime( trim( (string)$xpath->evaluate( 'string(pubDate)', $item ) ) );
            $items[] = array(
                'hash'   => sha1( $url ),
                'id'     => sha1( $url ),
                'title'  => $title !== '' ? $title : $url,
                'reply'  => $reply,
                'author' => self::authorName( $author ),
                'time'   => $time === false ? 0 : (int)$time,
                'url'    => $url,
            );
        }
        return $items;
    }

    /**
     * A link of the feed on the forum's own address: http(s) on one of $hosts, rebuilt on $base with its path, query
     * and fragment; null otherwise.
     */
    public static function onHost( $link, array $hosts, $base )
    {
        $parts = parse_url( $link );
        if ( !is_array( $parts ) || !isset( $parts['scheme'], $parts['host'] ) || !in_array( strtolower( $parts['scheme'] ), array( 'http', 'https' ), true )
             || !in_array( strtolower( $parts['host'] ), $hosts, true ) || isset( $parts['user'] ) || isset( $parts['pass'] ) )
        {
            return null;
        }
        $path = isset( $parts['path'] ) && $parts['path'] !== '' ? $parts['path'] : '/';
        if ( preg_match( '#[\s"\'<>\\\\]#', $path ) )
            return null;
        return $base . $path . ( isset( $parts['query'] ) ? '?' . $parts['query'] : '' ) . ( isset( $parts['fragment'] ) ? '#' . $parts['fragment'] : '' );
    }

    /**
     * The name of an RSS author: "Name ( http://... )" and "mail (Name)" give Name; a bare mail address gives nothing.
     */
    public static function authorName( $author )
    {
        $author = self::plain( $author, 200, true );
        if ( preg_match( '#^(.*?)\s*\(\s*https?://[^)]*\)$#i', $author, $m ) )
            $author = trim( $m[1] );
        elseif ( preg_match( '/^\S+@\S+\s*\((.+)\)$/', $author, $m ) )
            $author = trim( $m[1] );
        if ( strpos( $author, '@' ) !== false )
            return '';
        return self::plain( $author, self::MAX_AUTHOR, true );
    }
}
