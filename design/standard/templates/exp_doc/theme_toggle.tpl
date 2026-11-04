{* admin4's color mode switch (design/admin4/templates/page_topmenu.tpl, the div#header-theme), for the Modern
   documentation header: the markup below is the kernel's, unchanged (tests/ComponentsCopyTest.php keeps it equal);
   javascript/a4_head.js (the kernel's, copied) wires it, stylesheets/a4-theme-toggle.css draws it. *}
    <div id="header-theme" class="header-theme">
        <button type="button" id="a4-theme-toggle" class="a4-theme-toggle"
                title="{'Switch to dark mode'|i18n( 'design/admin/pagelayout' )|wash}"
                data-label-light="{'Color mode: light'|i18n( 'design/admin/pagelayout' )|wash}"
                data-label-dark="{'Color mode: dark'|i18n( 'design/admin/pagelayout' )|wash}"
                data-label-system="{'Color mode: system'|i18n( 'design/admin/pagelayout' )|wash}"
                data-title-light="{'Switch to dark mode'|i18n( 'design/admin/pagelayout' )|wash}"
                data-title-dark="{'Switch to system mode'|i18n( 'design/admin/pagelayout' )|wash}"
                data-title-system="{'Switch to light mode'|i18n( 'design/admin/pagelayout' )|wash}">
            <span class="a4-icon a4-bi-sun a4-icon-sun" aria-hidden="true"></span>
            <span class="a4-icon a4-bi-moon a4-icon-moon" aria-hidden="true"></span>
            <span class="a4-icon a4-bi-circle-half a4-icon-system" aria-hidden="true"></span>
            <span class="a4-theme-label">{'Color mode: light'|i18n( 'design/admin/pagelayout' )}</span>
        </button>
        <span id="a4-theme-status" class="a4-sr-only" role="status"></span>
    </div>
