<?php
/**
 * expDocForumFeed (the front page's "Recent forum activity"): the RSS 2.0 parsing, the links kept on the feed's own
 * host, the author names, the excluded titles, and that each read replaces the list while a failed read keeps the
 * last good one. No database and no network: the feed comes from tests/fixtures/forum_feed.rss through a test
 * fetcher. Needs the kernel's expHelpCommitFeed (from the installation's autoload, else the installation three levels
 * above this directory); skipped without it.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class ExpDocForumFeedTest extends \PHPUnit\Framework\TestCase
{
    const FEED = 'https://share.mirror.example.org/rss/feed/all_forums';

    protected function setUp(): void
    {
        if ( !class_exists( 'expHelpCommitFeed' ) )
        {
            $kernel = dirname( __DIR__, 3 ) . '/kernel/classes/help/exphelpcommitfeed.php';
            if ( !is_file( $kernel ) )
            {
                $this->markTestSkipped( 'No kernel expHelpCommitFeed' );
            }
            require_once $kernel;
        }
        if ( !class_exists( 'expDocForumFeed', false ) )
        {
            require_once dirname( __DIR__ ) . '/classes/expdocforumfeed.php';
        }
    }

    private static function fixture()
    {
        return file_get_contents( __DIR__ . '/fixtures/forum_feed.rss' );
    }

    private static function feed( array $options = array(), $fetcher = null )
    {
        return new expDocForumFeed( $options + array( 'feed' => self::FEED, 'cacheDir' => null, 'exclude' => array(),
                                                      'enabled' => true, 'limit' => 8 ), $fetcher );
    }

    public function testParsesRssItemsAsPlainTextOnTheFeedsHost()
    {
        $items = self::feed()->parse( self::fixture() );
        $this->assertSame( array( 'Buy cheap things', 'How do I cache a block?', 'How do I cache a block?', 'Mail author' ),
                           array_column( $items, 'title' ), 'items on other hosts or without a web link are left out' );
        $this->assertSame( array( false, true, false, false ), array_column( $items, 'reply' ) );
        $this->assertSame( array( 'https://share.mirror.example.org/forums/suggestions/buy-cheap-things',
                                  'https://share.mirror.example.org/forums/developer/how-do-i-cache-a-block/comment7?x=1#c7',
                                  'https://share.mirror.example.org/forums/developer/how-do-i-cache-a-block',
                                  'https://share.mirror.example.org/forums/general/mail-author' ),
                           array_column( $items, 'url' ), 'links are rebuilt on the feed\'s own host' );
        $this->assertSame( array( 'Spam Sender', 'Ada Example', 'Grace Example', '' ), array_column( $items, 'author' ),
                           'names only: no profile links, no mail addresses' );
        $this->assertSame( strtotime( 'Sat, 28 Feb 2026 04:57:52 +0000' ), $items[1]['time'] );
        foreach ( $items as $item )
        {
            $this->assertSame( array( 'hash', 'id', 'title', 'reply', 'author', 'time', 'url' ), array_keys( $item ),
                               'nothing else of the feed (descriptions, markup) is kept' );
        }
    }

    public function testRejectsWhatIsNotRss()
    {
        $feed = self::feed();
        $this->assertNull( $feed->parse( '<feed xmlns="http://www.w3.org/2005/Atom"></feed>' ) );
        $this->assertNull( $feed->parse( 'not xml' ) );
        $this->assertNull( $feed->parse( '<!DOCTYPE rss [<!ENTITY x SYSTEM "file:///etc/passwd">]><rss><channel/></rss>' ) );
    }

    public function testExcludedTitlesAndLimit()
    {
        $fetch = function () { return self::fixture(); };
        $all = self::feed( array(), $fetch )->items( null, 1000000 );
        $this->assertCount( 4, $all['items'] );
        $this->assertFalse( $all['stale'] );
        $this->assertSame( 'https://share.example.org/forums',
                           self::feed( array( 'forum' => 'https://share.example.org/forums' ), $fetch )->items( null, 1000000 )['more'] );

        $some = self::feed( array( 'exclude' => array( '*CHEAP*', 'mail' ) ), $fetch )->items( 2, 1000000 );
        $this->assertSame( array( 'How do I cache a block?', 'How do I cache a block?' ), array_column( $some['items'], 'title' ),
                           'patterns are case-insensitive and match the whole title; the limit counts what is shown' );
    }

    public function testEachReadReplacesTheListAndAFailedReadKeepsIt()
    {
        if ( !class_exists( 'eZDir' ) || !class_exists( 'eZFile' ) )
        {
            $this->markTestSkipped( 'The cache needs the kernel\'s eZDir and eZFile' );
        }
        $dir = getcwd() . '/var/tmp/phpunit-exp-doc-forum-' . getmypid() . '-' . mt_rand();
        mkdir( $dir, 0777, true );
        try
        {
            $calls = 0;
            $body = self::fixture();
            $fetch = function () use ( &$calls, &$body ) { ++$calls; return $body; };
            $options = array( 'cacheDir' => $dir, 'ttl' => 600, 'retry' => 120 );
            $now = 1000000;

            $first = self::feed( $options, $fetch )->items( null, $now );
            $this->assertSame( 1, $calls );
            $this->assertCount( 4, $first['items'] );
            self::feed( $options, $fetch )->items( null, $now + 300 );
            $this->assertSame( 1, $calls, 'within the cache time the cache answers' );

            // the first post was removed from the forums: it leaves the list with the next read
            $body = preg_replace( '#<item>\s*<title>Buy cheap things</title>.*?</item>#s', '', $body, 1 );
            $second = self::feed( $options, $fetch )->items( null, $now + 700 );
            $this->assertSame( 2, $calls );
            $this->assertNotContains( 'Buy cheap things', array_column( $second['items'], 'title' ) );
            $this->assertCount( 3, $second['items'] );

            // offline: the last good list stays, marked stale
            $body = false;
            $offline = self::feed( $options, $fetch )->items( null, $now + 1400 );
            $this->assertSame( 3, $calls );
            $this->assertTrue( $offline['stale'] );
            $this->assertSame( 'unreachable', $offline['error'] );
            $this->assertCount( 3, $offline['items'] );
            $this->assertSame( $now + 700, $offline['fetched'] );
        }
        finally
        {
            foreach ( (array)glob( $dir . '/{,.}[!.]*', GLOB_BRACE ) as $file )
            {
                unlink( $file );
            }
            @rmdir( $dir );
        }
    }
}
