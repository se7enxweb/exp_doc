{* The header of a Modern page: the brand, the search with suggestions (the kernel's front search), the version
   switch of the page's manual, the Classic / Modern and language switches, the round button to the recent changes
   (doc/recent), admin4's color mode switch (exp_doc/theme_toggle.tpl), and the menu
   button that opens the page tree on a phone. *}
<header class="exp-doc-header">
    <div class="exp-doc-header-inner">
        <button type="button" class="a4-btn exp-doc-tree-button" aria-controls="exp-doc-tree" aria-expanded="false" data-exp-doc-tree-button hidden>
            <span class="a4-sr-only">{'Show the page tree'|i18n( 'design/exp_doc' )}</span>
            <span aria-hidden="true">&#9776;</span>
        </button>
        <a class="exp-doc-brand" href={'/'|ezurl}>
            {include uri='design:exp_doc/logo.tpl'}
            <span class="exp-doc-brand-sub">{'Documentation'|i18n( 'design/exp_doc' )}</span>
        </a>
        <form class="exp-doc-search" role="search" method="post" action={'content/search'|ezurl}>
            <label class="a4-sr-only" for="exp-doc-search-text">{'Search the documentation'|i18n( 'design/exp_doc' )}</label>
            <input type="search" id="exp-doc-search-text" name="SearchText" class="exp-doc-search-input"
                   placeholder="{'Search the documentation'|i18n( 'design/exp_doc' )}" autocomplete="off">
            <button type="submit" class="a4-btn exp-doc-search-button" name="SearchButton">{'Search'|i18n( 'design/exp_doc' )}</button>
            {include uri='design:parts/front_search_suggest.tpl' suggest_id='exp-doc-search-text'}
        </form>
        <div class="exp-doc-header-tools">
            {if $node}{include uri='design:parts/doc_version_switch.tpl' node=$node}{/if}
            {include uri='design:exp_doc/switches.tpl'}
            <a class="a4-btn exp-doc-icon-button" href={ezini( 'RecentSettings', 'Path', 'exp_doc.ini' )|ezurl} title="{'Recent changes'|i18n( 'design/exp_doc' )}" aria-label="{'Recent changes'|i18n( 'design/exp_doc' )}"><span class="a4-icon a4-bi-clock-history" aria-hidden="true"></span></a>
            {include uri='design:exp_doc/theme_toggle.tpl'}
        </div>
    </div>
</header>
