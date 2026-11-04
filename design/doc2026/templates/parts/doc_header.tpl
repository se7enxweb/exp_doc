{* The header of a Modern page: the brand, the search with suggestions (the kernel's front search), the version
   switch of the page's manual, the Classic / Modern and language switches, the color mode switch, and the menu
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
            <button type="button" class="a4-btn exp-doc-theme" id="exp-doc-theme" data-exp-doc-theme hidden
                    aria-label="{'Color mode'|i18n( 'design/exp_doc' )}">
                <span data-exp-doc-theme-label>{'System'|i18n( 'design/exp_doc' )}</span>
            </button>
        </div>
    </div>
</header>
