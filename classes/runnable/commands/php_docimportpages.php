<?php
/**
 * exp:doc:import (ext:exp_doc:doc-import-pages): the static import of exp_static_html_imports with the documentation
 * site's type, --doc-html, chosen. Every option of exp:static-import:run works here too.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

namespace Exponential\Command\Extension\ExpDoc
{

class DocImportPages extends \Exponential\Command\Extension\ExpStaticHtmlImports\Run
{
    public function run()
    {
        // the documentation type unless the caller chose one
        $argv = isset( $_SERVER['argv'] ) ? $_SERVER['argv'] : array();
        $hasType = false;
        foreach ( $argv as $arg )
            if ( strpos( $arg, '--type' ) === 0 || in_array( ltrim( $arg, '-' ), array_keys( \expStaticImportRegistry::types() ), true ) )
                $hasType = true;
        if ( !$hasType )
        {
            $_SERVER['argv'][] = '--doc-html';
            $GLOBALS['argv'] = $_SERVER['argv'];
        }
        return parent::run();
    }
}

}
