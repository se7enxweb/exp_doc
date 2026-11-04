<?php
/**
 * The Modern design's copy of the administration's components.css (design/doc2026/stylesheets/components.css) must
 * stay the kernel's file (design/admin4/stylesheets/components.css) after its own leading comment, so the documentation
 * builds on exactly the help center's tokens and classes. Run inside an installation (the kernel's file is read from
 * the installation root, three levels above this extension's tests directory); skipped when the kernel's file is
 * not there.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class ExpDocComponentsCopyTest extends \PHPUnit\Framework\TestCase
{
    public function testTheModernDesignCarriesTheKernelsComponents()
    {
        $kernel = dirname( __DIR__, 3 ) . '/design/admin4/stylesheets/components.css';
        if ( !is_file( $kernel ) )
        {
            $this->markTestSkipped( 'No kernel components.css at ' . $kernel );
        }
        $copy = file_get_contents( dirname( __DIR__ ) . '/design/doc2026/stylesheets/components.css' );
        // the copy starts with its own comment, then the kernel's file unchanged
        $end = strpos( $copy, "*/\n" );
        $this->assertNotFalse( $end, 'The copy has no leading comment' );
        // the icon addresses climb two more folders from extension/exp_doc/design/doc2026/stylesheets/
        $expected = str_replace( 'url(../../../share/icons/', 'url(../../../../../share/icons/', file_get_contents( $kernel ) );
        $this->assertSame( $expected, substr( $copy, $end + 3 ),
                           'design/doc2026/stylesheets/components.css differs from the kernel\'s design/admin4/stylesheets/components.css: copy it again' );
    }
}
