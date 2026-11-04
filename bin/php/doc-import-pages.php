#!/usr/bin/env php
<?php
/**
 * Import the static documentation site (--doc-html) into the Documentation site, or bring it in step with its source
 *
 * Usage:
 *   ./console exp:doc:import [options]   (or ext:exp_doc:doc-import-pages, or php extension/exp_doc/bin/php/doc-import-pages.php)
 *   --help shows the options; they are the options of exp:static-import:run, with --doc-html chosen.
 *
 * @alias exp:doc:import
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

require_once dirname( __FILE__ ) . '/../../../../autoload.php';

// The code is in extension/exp_doc/classes/runnable/commands/php_docimportpages.php; this file is the entry point.
\Exponential\Command\Extension\ExpDoc\DocImportPages::main( __FILE__ );
