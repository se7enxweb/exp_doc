<?php
/**
 * Cronjob part of exp_doc (frequent, settings/cronjob.ini.append.php): counts the roles of the Contributors page again
 * (expDocContributorCounts) when something was published since they were last counted, so the page view reads them
 * from the cache file instead of counting over every page. Nothing is done while nothing was published.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

// @description Counts the Contributors page's roles again after a publish

$start = microtime( true );
$counts = expDocContributorCounts::refresh();
if ( isset( $cli ) && $cli instanceof eZCLI && empty( $isQuiet ) )
{
    $cli->output( $counts === null
                  ? 'exp_doc contributor counts: current, nothing published since'
                  : sprintf( 'exp_doc contributor counts: counted in %.1f s (%d writers, %d updaters, %d maintainers, %d commenters)',
                             microtime( true ) - $start, count( $counts['written'] ), count( $counts['updated'] ),
                             count( $counts['maintained'] ), count( $counts['comments'] ) ) );
}
