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
        $copy = file_get_contents( dirname( __DIR__ ) . '/design/standard/stylesheets/components.css' );
        // the copy starts with its own comment, then the kernel's file unchanged
        $end = strpos( $copy, "*/\n" );
        $this->assertNotFalse( $end, 'The copy has no leading comment' );
        // the icon addresses climb two more folders from extension/exp_doc/design/standard/stylesheets/
        $expected = str_replace( 'url(../../../share/icons/', 'url(../../../../../share/icons/', file_get_contents( $kernel ) );
        $this->assertSame( $expected, substr( $copy, $end + 3 ),
                           'design/standard/stylesheets/components.css differs from the kernel\'s design/admin4/stylesheets/components.css: copy it again' );
    }

    /**
     * The Modern header's color mode switch is admin4's own (the owner: exactly admin4's theme control): its script
     * byte for byte, its markup and its stylesheet block unchanged after the copies' leading comments.
     */
    public function testTheColorModeSwitchIsAdmin4s()
    {
        $root = dirname( __DIR__, 3 );
        $script = $root . '/design/admin4/javascript/a4_head.js';
        if ( !is_file( $script ) )
        {
            $this->markTestSkipped( 'No kernel a4_head.js at ' . $script );
        }
        $own = dirname( __DIR__ ) . '/design/standard';
        $this->assertSame( file_get_contents( $script ), file_get_contents( $own . '/javascript/a4_head.js' ),
                           'javascript/a4_head.js differs from the kernel\'s design/admin4/javascript/a4_head.js: copy it again' );

        $topmenu = file_get_contents( $root . '/design/admin4/templates/page_topmenu.tpl' );
        $this->assertSame( 1, preg_match( '#^    <div id="header-theme" class="header-theme">\n.*?\n    </div>\n#ms', $topmenu, $markup ) );
        $part = file_get_contents( $own . '/templates/exp_doc/theme_toggle.tpl' );
        $this->assertSame( $markup[0], substr( $part, strpos( $part, "*}\n" ) + 3 ),
                           'templates/exp_doc/theme_toggle.tpl differs from the div#header-theme of the kernel\'s page_topmenu.tpl: copy it again' );

        $css = file_get_contents( $root . '/design/admin4/stylesheets/admin4.css' );
        $this->assertSame( 1, preg_match( '#^/\* The light/dark toggle, after the search box \*/\n.*?^\.header-theme \{ gap: var\(--a4-space-2\); \}\n#ms', $css, $block ) );
        $copy = file_get_contents( $own . '/stylesheets/a4-theme-toggle.css' );
        $this->assertSame( $block[0], substr( $copy, strpos( $copy, " */\n" ) + 4 ),
                           'stylesheets/a4-theme-toggle.css differs from the switch\'s block of the kernel\'s admin4.css: copy it again' );
    }
}
