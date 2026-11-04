{* The landing page of the Modern design (the front page), in the help center's components and their color fades:
   - a large search in the hero (.a4-help-hero), its heading the official logo (named "Exponential" for screen
     readers) and exp_doc.ini [ModernSettings] LandingHeading;
   - a card for every manual (its cover or icon, summary and audience, and its versions), .a4-help-about and
     .a4-help-grow in turn;
   - the products (fetch exp_doc/products: the containers once they exist, else [ModernSettings] ProductList[]),
     the same cards with the Supported badge where it applies;
   - the recently changed pages and the most read pages (the kernel's view counts, no third-party tracker), each in
     an .a4-help-support box. *}
{def $doc_manuals = fetch( 'content', 'tree', hash( 'parent_node_id', $node.node_id,
                                                     'class_filter_type', 'include', 'class_filter_array', array( 'exp_doc_manual' ),
                                                     'sort_by', array( 'priority', true() ), 'limit', 24 ) )
     $doc_recent = fetch( 'content', 'tree', hash( 'parent_node_id', $node.node_id,
                                                    'class_filter_type', 'include', 'class_filter_array', ezini( 'ModernSettings', 'PageClasses', 'exp_doc.ini' ),
                                                    'sort_by', array( 'modified', false() ), 'limit', 8 ) )
     $doc_popular = fetch( 'content', 'view_top_list', hash( 'limit', 8 ) )}
<section class="a4-help-hero exp-doc-hero" aria-labelledby="exp-doc-hero-title">
    <h1 id="exp-doc-hero-title" class="exp-doc-hero-title"><span class="exp-doc-hero-logo">{include uri='design:exp_doc/logo.tpl'}</span> {ezini( 'ModernSettings', 'LandingHeading', 'exp_doc.ini' )|wash}</h1>
    <p class="a4-help-hero-sub">{ezini( 'ModernSettings', 'LandingText', 'exp_doc.ini' )|wash}</p>
    <form class="exp-doc-hero-search" role="search" method="post" action={'content/search'|ezurl}>
        <label class="a4-sr-only" for="exp-doc-hero-search-text">{'Search the documentation'|i18n( 'design/exp_doc' )}</label>
        <input type="search" id="exp-doc-hero-search-text" name="SearchText" placeholder="{'What are you looking for?'|i18n( 'design/exp_doc' )}" autocomplete="off">
        <button type="submit" class="a4-btn is-primary" name="SearchButton">{'Search'|i18n( 'design/exp_doc' )}</button>
        {include uri='design:parts/front_search_suggest.tpl' suggest_id='exp-doc-hero-search-text'}
    </form>
    <p class="a4-meta exp-doc-hero-help">{'Guides, manuals and the reference of this Exponential installation, in English and German.'|i18n( 'design/exp_doc' )}</p>
    <p class="a4-help-hero-actions"><a class="a4-btn" href={'exphelp/dashboard'|ezurl}>{'Open the help center'|i18n( 'design/exp_doc' )}</a> <a class="a4-btn" href={'exphelp/contents'|ezurl}><span class="a4-icon a4-bi-list-ul" aria-hidden="true"></span> {'Browse all help'|i18n( 'design/exp_doc' )}</a></p>
</section>

{if $doc_manuals|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-manuals-title">
    <h2 id="exp-doc-manuals-title" class="a4-h2">{'Manuals'|i18n( 'design/exp_doc' )}</h2>
    <ul class="a4-plain exp-doc-manuals">
    {foreach $doc_manuals as $doc_manual}
        {def $doc_versions = fetch( 'exp_doc', 'versions', hash( 'parent_node_id', $doc_manual.node_id ) )}
        <li class="{cond( $doc_manual.number|mod( 2 ), 'a4-help-grow', 'a4-help-about' )} exp-doc-manual">
            <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon a4-bi-journal-text"></span></span>
            <div class="exp-doc-manual-body">
            {if and( is_set( $doc_manual.data_map.cover ), $doc_manual.data_map.cover.has_content )}
            <img class="exp-doc-manual-cover" src={$doc_manual.data_map.cover.content.medium.url|ezroot} alt="" width="{$doc_manual.data_map.cover.content.medium.width}" height="{$doc_manual.data_map.cover.content.medium.height}" loading="lazy">
            {/if}
            <h3 class="exp-doc-manual-name"><a href={$doc_manual.url_alias|ezurl}>{$doc_manual.name|wash}</a></h3>
            {if is_set( $doc_manual.data_map.summary )}<div class="exp-doc-manual-summary">{attribute_view_gui attribute=$doc_manual.data_map.summary}</div>{/if}
            {if and( is_set( $doc_manual.data_map.audience ), $doc_manual.data_map.audience.has_content )}<p class="a4-meta">{'For: %audience'|i18n( 'design/exp_doc', '', hash( '%audience', $doc_manual.data_map.audience.content|wash ) )}</p>{/if}
            {if $doc_versions|count}
            <ul class="a4-plain exp-doc-manual-versions" aria-label="{'Versions'|i18n( 'design/exp_doc' )}">
                {foreach $doc_versions as $doc_v}<li>{include uri='design:parts/doc_version_tag.tpl' version=$doc_v label=cond( $doc_v.data_map.version.has_content, $doc_v.data_map.version.content, $doc_v.name )}</li>{/foreach}
            </ul>
            {/if}
            </div>
        </li>
        {undef $doc_versions}
    {/foreach}
    </ul>
</section>
{/if}

{* the products (fetch exp_doc/products, [ModernSettings] ProductList[]): the same faded cards as the manuals *}
{def $doc_products = fetch( 'exp_doc', 'products' )
     $doc_supported = ezini( 'ModernSettings', 'SupportedStatuses', 'exp_doc.ini' )}
{if $doc_products|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-products-title">
    <h2 id="exp-doc-products-title" class="a4-h2">{'Products'|i18n( 'design/exp_doc' )}</h2>
    <ul class="a4-plain exp-doc-manuals exp-doc-products">
    {foreach $doc_products as $doc_index => $doc_product}
        <li class="{cond( $doc_index|mod( 2 ), 'a4-help-grow', 'a4-help-about' )} exp-doc-manual{if $doc_supported|contains( $doc_product.status )} is-supported{/if}">
            <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon {cond( eq( $doc_product.path, 'exponential' ), 'a4-bi-journal-text', 'a4-bi-box-seam' )}"></span></span>
            <div class="exp-doc-manual-body">
                <h3 class="exp-doc-manual-name"><a href={$doc_product.path|ezurl}>{$doc_product.name|wash}</a>{if $doc_supported|contains( $doc_product.status )} <span class="exp-doc-version-badge is-supported">{'Supported'|i18n( 'design/exp_doc' )}</span>{/if}</h3>
                {if $doc_product.text}<p class="exp-doc-manual-summary">{$doc_product.text|wash}</p>{/if}
            </div>
        </li>
    {/foreach}
    </ul>
</section>
{/if}
{undef $doc_products $doc_supported}

<div class="exp-doc-landing-columns">
{if $doc_recent|count}
<section class="a4-help-support exp-doc-landing-section" aria-labelledby="exp-doc-recent-title">
    <h2 id="exp-doc-recent-title" class="a4-h2">{'Recently changed'|i18n( 'design/exp_doc' )}</h2>
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_recent as $doc_item}
        <li><a href={$doc_item.url_alias|ezurl}>{$doc_item.name|wash}</a> <span class="a4-meta">{$doc_item.object.modified|l10n( 'shortdate' )}</span></li>
    {/foreach}
    </ol>
    <p class="exp-doc-landing-more"><a href={ezini( 'RecentSettings', 'Path', 'exp_doc.ini' )|ezurl}>{'See all changes'|i18n( 'design/exp_doc' )}</a></p>
</section>
{/if}
{* the pages added last: newest first by their first publication on this site (the object's published date) *}
{def $doc_added = fetch( 'exp_doc', 'recent_pages', hash( 'mode', 'new', 'limit', 8 ) )}
{if $doc_added|count}
<section class="a4-help-support exp-doc-landing-section is-accent" aria-labelledby="exp-doc-added-title">
    <h2 id="exp-doc-added-title" class="a4-h2">{'Recently added'|i18n( 'design/exp_doc' )}</h2>
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_added as $doc_item}
        <li><a href={$doc_item.url|ezurl}>{$doc_item.title|wash}</a>
            <span class="a4-meta">{if $doc_item.manual}{$doc_item.manual.name|wash}{if $doc_item.version} {$doc_item.version.name|wash}{/if} · {/if}{if $doc_item.author}{$doc_item.author.name|wash} · {/if}{$doc_item.published|l10n( 'shortdate' )}</span>
            {if $doc_item.excerpt}<span class="exp-doc-landing-excerpt">{$doc_item.excerpt|shorten( 120 )|wash}</span>{/if}</li>
    {/foreach}
    </ol>
    <p class="exp-doc-landing-more"><a href={ezini( 'RecentSettings', 'NewPath', 'exp_doc.ini' )|ezurl}>{'See all new pages'|i18n( 'design/exp_doc' )}</a></p>
</section>
{/if}
{undef $doc_added}
{* the newest approved readers' comments (never a held one), each linked to the comment on its page *}
{def $doc_comments = fetch( 'exp_doc', 'recent_comments', hash( 'limit', 8 ) )}
<section class="a4-help-support exp-doc-landing-section" aria-labelledby="exp-doc-comments-title">
    <h2 id="exp-doc-comments-title" class="a4-h2">{'Recent comments'|i18n( 'design/exp_doc' )}</h2>
    {if $doc_comments|count}
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_comments as $doc_c}
        <li><a href={concat( $doc_c.page.url_alias, '#', $doc_c.anchor )|ezurl}>{$doc_c.subject|wash}</a> <span class="a4-meta">{if $doc_c.name|ne( '' )}{$doc_c.name|wash} · {/if}{$doc_c.date|l10n( 'shortdate' )} · {'on %page'|i18n( 'design/exp_doc', '', hash( '%page', $doc_c.page.name|wash ) )}</span></li>
    {/foreach}
    </ol>
    {else}
    <p class="a4-meta">{'No comments yet. Every page has a form for yours.'|i18n( 'design/exp_doc' )}</p>
    {/if}
    <p class="exp-doc-landing-more"><a href={ezini( 'RecentSettings', 'CommentsPath', 'exp_doc.ini' )|ezurl}>{'See all comments'|i18n( 'design/exp_doc' )}</a></p>
</section>
{undef $doc_comments}
{* the newest ratings of pages a reader may open (never who rated), each with the stars given, how long ago, and the
   page's average now *}
{def $doc_ratings = fetch( 'exp_doc', 'recent_ratings', hash( 'limit', 8 ) )}
<section class="a4-help-support exp-doc-landing-section is-info" aria-labelledby="exp-doc-ratings-title">
    <h2 id="exp-doc-ratings-title" class="a4-h2">{'Recent ratings'|i18n( 'design/exp_doc' )}</h2>
    {if $doc_ratings|count}
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_ratings as $doc_r}
        {set-block variable=$doc_ago}{include uri='design:exp_doc/time_ago.tpl' time=$doc_r.time}{/set-block}
        <li><a href={$doc_r.node.url_alias|ezurl}>{$doc_r.node.name|wash}</a> {include uri='design:exp_doc/rating_stars.tpl' rating=hash( 'rating_average', $doc_r.stars, 'rating_count', 1 )} <span class="a4-meta">{'%age ago'|i18n( 'design/exp_doc', '', hash( '%age', $doc_ago|trim ) )} · <span>{'The page now: %average of 5, %count ratings'|i18n( 'design/exp_doc', '', hash( '%average', $doc_r.average, '%count', $doc_r.count ) )}</span></span></li>
    {/foreach}
    </ol>
    {else}
    <p class="a4-meta">{'No ratings yet. Every page has stars for yours.'|i18n( 'design/exp_doc' )}</p>
    {/if}
    <p class="exp-doc-landing-more"><a href={ezini( 'RecentSettings', 'RatingsPath', 'exp_doc.ini' )|ezurl}>{'See all ratings'|i18n( 'design/exp_doc' )}</a></p>
</section>
{undef $doc_ratings}
{if $doc_popular|count}
<section class="a4-help-support exp-doc-landing-section" aria-labelledby="exp-doc-popular-title">
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
