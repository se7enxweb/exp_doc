<?php
/**
 * File containing the expDocContributorCounts class.
 *
 * The role counts of the Contributors page (expDocFetch::people(), fetch exp_doc/contributor_list and
 * commenter_list): for every contributor object, the pages that name them as writer (written_by), last updater
 * (last_updated_by) and maintainer (maintainers), current versions of published objects only, and the historical
 * comments they wrote (how many, and the newest one's written date).
 *
 * The counts are aggregates over every page (the attribute rows of every version: about 3 s on the documentation's
 * database), so they are kept in a cache file (var/<site>/cache/exp_doc/contributor-counts.php) instead of being counted
 * by the page view:
 * - the cronjob part exp_doc_contributor_counts.php (frequent) counts again when something was published since the
 *   counts were last counted (the template-block expiry every publish sets), so they follow a publish within one run;
 * - a page view counts only when there is no file yet (a new installation, a cleared cache directory).
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocContributorCounts
{
    const CACHE_FILE = 'contributor-counts.php';

    /**
     * The counts: from the cache file, else counted now and stored.
     *
     * @return array array( 'written', 'updated', 'maintained' => array( contributor object id => pages ),
     *               'comments' => array( contributor object id => array( count, newest written date ) ), 'time' )
     */
    public static function get()
    {
        $cached = self::read();
        return $cached !== null ? $cached : self::refresh( true );
    }

    /**
     * Counts again and stores the result when something was published after the last counting started (or there is
     * no file, or $force).
     *
     * @param bool $force
     * @return array|null the new counts, null when the file was current
     */
    public static function refresh( $force = false )
    {
        $file = self::file();
        // compared with the time the counting started, so a publish while counting is counted by the next run
        $cached = $force ? null : self::read();
        if ( $cached !== null && (int)$cached['time'] > self::publishedAt() )
        {
            return null;
        }
        $counts = self::count();
        $dir = dirname( $file );
        if ( is_dir( $dir ) || eZDir::mkdir( $dir, false, true ) )
        {
            // written whole and renamed, so a page view never reads half a file
            $tmp = $file . '.' . getmypid() . '.tmp';
            if ( file_put_contents( $tmp, '<?php return ' . var_export( $counts, true ) . ";\n" ) !== false )
            {
                rename( $tmp, $file );
                if ( function_exists( 'opcache_invalidate' ) )
                {
                    opcache_invalidate( $file, true );
                }
            }
        }
        return $counts;
    }

    /**
     * The time of the last publish anywhere (the template-block expiry, which every publish sets), 0 when never.
     *
     * @return int
     */
    public static function publishedAt()
    {
        return (int)eZExpiryHandler::instance()->getTimestamp( 'template-block-cache', 0 );
    }

    /** @return string the cache file */
    public static function file()
    {
        return eZSys::cacheDirectory() . '/exp_doc/' . self::CACHE_FILE;
    }

    /** @return array|null the cached counts, null when there are none */
    protected static function read()
    {
        $file = self::file();
        if ( !is_file( $file ) )
        {
            return null;
        }
        $data = @include $file;
        return is_array( $data ) && isset( $data['written'], $data['updated'], $data['maintained'], $data['comments'] ) ? $data : null;
    }

    /**
     * Counts every role: one aggregate query per role, never one per person.
     *
     * @return array see get()
     */
    public static function count()
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $db = eZDB::instance();
        $attributeIDs = function ( $identifier ) use ( $db )
        {
            $rows = $db->arrayQuery( "SELECT id FROM ezcontentclass_attribute WHERE version = 0 AND identifier = '" . $db->escapeString( $identifier ) . "'" );
            $ids = array_map( 'intval', array_column( $rows, 'id' ) );
            return $ids ? implode( ',', $ids ) : '0';
        };
        $counts = array( 'written' => array(), 'updated' => array(), 'maintained' => array(), 'comments' => array(), 'time' => time() );
        // the single relations from the attribute data, the relation list from the links
        foreach ( array( 'written' => 'written_by', 'updated' => 'last_updated_by' ) as $key => $identifier )
        {
            foreach ( $db->arrayQuery( "SELECT ca.data_int AS id, COUNT(*) AS n FROM ezcontentobject_attribute ca, ezcontentobject o
                                        WHERE ca.contentclassattribute_id IN ( " . $attributeIDs( $identifier ) . " ) AND ca.data_int > 0
                                        AND o.id = ca.contentobject_id AND o.current_version = ca.version AND o.status = 1
                                        GROUP BY ca.data_int" ) as $row )
            {
                $counts[$key][(int)$row['id']] = (int)$row['n'];
            }
        }
        foreach ( $db->arrayQuery( "SELECT l.to_contentobject_id AS id, COUNT( DISTINCT l.from_contentobject_id ) AS n
                                    FROM ezcontentobject_link l, ezcontentobject o
                                    WHERE l.contentclassattribute_id IN ( " . $attributeIDs( 'maintainers' ) . " )
                                    AND o.id = l.from_contentobject_id AND o.current_version = l.from_contentobject_version AND o.status = 1
                                    GROUP BY l.to_contentobject_id" ) as $row )
        {
            $counts['maintained'][(int)$row['id']] = (int)$row['n'];
        }
        // the comments: the historical comments' author relation, how many and the newest one's written date, in one
        // aggregate (the readers' new comments name their author as text, so they are not counted here)
        $commentClass = (string)$ini->variable( 'ClassicSettings', 'CommentClass' );
        $classAttribute = function ( $identifier ) use ( $db, $commentClass )
        {
            $rows = $db->arrayQuery( "SELECT a.id FROM ezcontentclass_attribute a, ezcontentclass c WHERE a.version = 0 AND c.version = 0
                                      AND a.contentclass_id = c.id AND c.identifier = '" . $db->escapeString( $commentClass ) . "'
                                      AND a.identifier = '" . $db->escapeString( $identifier ) . "'" );
            return $rows ? (int)$rows[0]['id'] : 0;
        };
        $authorAttribute = $classAttribute( 'author' );
        $createdAttribute = $classAttribute( 'created' );
        if ( $authorAttribute )
        {
            foreach ( $db->arrayQuery( "SELECT ca.data_int AS id, COUNT(*) AS n, MAX( cd.data_int ) AS latest
                                        FROM ezcontentobject_attribute ca, ezcontentobject o, ezcontentobject_attribute cd
                                        WHERE ca.contentclassattribute_id = $authorAttribute AND ca.data_int > 0
                                        AND o.id = ca.contentobject_id AND o.current_version = ca.version AND o.status = 1
                                        AND cd.contentobject_id = ca.contentobject_id AND cd.version = ca.version
                                        AND cd.language_code = ca.language_code AND cd.contentclassattribute_id = " . (int)$createdAttribute . "
                                        GROUP BY ca.data_int" ) as $row )
            {
                $counts['comments'][(int)$row['id']] = array( (int)$row['n'], (int)$row['latest'] );
            }
        }
        return $counts;
    }
}
