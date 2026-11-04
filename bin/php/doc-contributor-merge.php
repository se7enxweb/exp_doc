#!/usr/bin/env php
<?php
/**
 * Merge duplicate contributors of the documentation site into the canonical one: every relation repointed, the
 * duplicates trashed, their addresses redirected
 *
 * Usage:
 *   ./console exp:doc:contributor-merge --into=<node or remote id> --from=<...> [--from=...] [--dry-run] [--purge]
 *   (or ext:exp_doc:doc-contributor-merge, or php extension/exp_doc/bin/php/doc-contributor-merge.php)
 *   --help shows the options.
 *
 * @alias exp:doc:contributor-merge
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

require_once dirname( __FILE__ ) . '/../../../../autoload.php';

// The code is in extension/exp_doc/classes/runnable/commands/php_doccontributormerge.php; this file is the entry point.
\Exponential\Command\Extension\ExpDoc\DocContributorMerge::main( __FILE__ );
