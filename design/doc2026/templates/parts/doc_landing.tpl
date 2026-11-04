{* The landing page of the Modern design (the front page): a large search, a card for every manual (its cover or
   icon, summary and audience, and its versions), the recently changed pages, and the most read pages (the
   kernel's view counts, no third-party tracker). *}
{def $doc_manuals = fetch( 'content', 'tree', hash( 'parent_node_id', $node.node_id,
                                                     'class_filter_type', 'include', 'class_filter_array', array( 'exp_doc_manual' ),
                                                     'sort_by', array( 'priority', true() ), 'limit', 24 ) )
     $doc_recent = fetch( 'content', 'tree', hash( 'parent_node_id', $node.node_id,
                                                    'class_filter_type', 'include', 'class_filter_array', ezini( 'ModernSettings', 'PageClasses', 'exp_doc.ini' ),
                                                    'sort_by', array( 'modified', false() ), 'limit', 8 ) )
     $doc_popular = fetch( 'content', 'view_top_list', hash( 'limit', 8 ) )}
<section class="exp-doc-hero" aria-labelledby="exp-doc-hero-title">
    <h1 id="exp-doc-hero-title" class="exp-doc-hero-title">{ezini( 'ModernSettings', 'LandingTitle', 'exp_doc.ini' )|wash}</h1>
    <p class="exp-doc-hero-text">{ezini( 'ModernSettings', 'LandingText', 'exp_doc.ini' )|wash}</p>
    <form class="exp-doc-hero-search" role="search" method="post" action={'content/search'|ezurl}>
        <label class="a4-sr-only" for="exp-doc-hero-search-text">{'Search the documentation'|i18n( 'design/exp_doc' )}</label>
        <input type="search" id="exp-doc-hero-search-text" name="SearchText" placeholder="{'What are you looking for?'|i18n( 'design/exp_doc' )}" autocomplete="off">
        <button type="submit" class="a4-btn is-primary" name="SearchButton">{'Search'|i18n( 'design/exp_doc' )}</button>
        {include uri='design:parts/front_search_suggest.tpl' suggest_id='exp-doc-hero-search-text'}
    </form>
</section>

{if $doc_manuals|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-manuals-title">
    <h2 id="exp-doc-manuals-title" class="a4-h2">{'Manuals'|i18n( 'design/exp_doc' )}</h2>
    <ul class="a4-plain exp-doc-manuals">
    {foreach $doc_manuals as $doc_manual}
        {def $doc_versions = fetch( 'exp_doc', 'versions', hash( 'parent_node_id', $doc_manual.node_id ) )}
        <li class="a4-card exp-doc-manual">
            {if and( is_set( $doc_manual.data_map.cover ), $doc_manual.data_map.cover.has_content )}
            <img class="exp-doc-manual-cover" src={$doc_manual.data_map.cover.content.medium.url|ezroot} alt="" width="{$doc_manual.data_map.cover.content.medium.width}" height="{$doc_manual.data_map.cover.content.medium.height}" loading="lazy">
            {/if}
            <h3 class="exp-doc-manual-name"><a href={$doc_manual.url_alias|ezurl}>{$doc_manual.name|wash}</a></h3>
            {if is_set( $doc_manual.data_map.summary )}<div class="exp-doc-manual-summary">{attribute_view_gui attribute=$doc_manual.data_map.summary}</div>{/if}
            {if and( is_set( $doc_manual.data_map.audience ), $doc_manual.data_map.audience.has_content )}<p class="a4-meta">{'For: %audience'|i18n( 'design/exp_doc', '', hash( '%audience', $doc_manual.data_map.audience.content|wash ) )}</p>{/if}
            {if $doc_versions|count}
            <ul class="a4-plain exp-doc-manual-versions" aria-label="{'Versions'|i18n( 'design/exp_doc' )}">
                {foreach $doc_versions as $doc_v}<li>{include uri='design:parts/doc_version_tag.tpl' version=$doc_v}</li>{/foreach}
            </ul>
            {/if}
        </li>
        {undef $doc_versions}
    {/foreach}
    </ul>
</section>
{/if}

<div class="exp-doc-landing-columns">
{if $doc_recent|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-recent-title">
    <h2 id="exp-doc-recent-title" class="a4-h2">{'Recently changed'|i18n( 'design/exp_doc' )}</h2>
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_recent as $doc_item}
        <li><a href={$doc_item.url_alias|ezurl}>{$doc_item.name|wash}</a> <span class="a4-meta">{$doc_item.object.modified|l10n( 'shortdate' )}</span></li>
    {/foreach}
    </ol>
</section>
{/if}
{if $doc_popular|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-popular-title">
    <h2 id="exp-doc-popular-title" class="a4-h2">{'Most read'|i18n( 'design/exp_doc' )}</h2>
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_popular as $doc_item}
        <li><a href={$doc_item.url_alias|ezurl}>{$doc_item.name|wash}</a></li>
    {/foreach}
    </ol>
</section>
{/if}
</div>
{undef $doc_manuals $doc_recent $doc_popular}
