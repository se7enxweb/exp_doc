{* The recent ratings (doc/ratings) in the Classic design: a page the static site did not have, so a listed exception
   of the exactness check, drawn in the static pages' frame and classes, with the same filters, days, entries, pages
   and feed as the Modern view. Who rated is never shown. Variables: see design/doc2026/templates/doc/ratings.tpl. *}
{def $doc_ranges = hash( 'all', 'Any time'|i18n( 'design/exp_doc' ),
                         '24h', 'Last 24 hours'|i18n( 'design/exp_doc' ),
                         '7d', 'Last 7 days'|i18n( 'design/exp_doc' ),
                         '30d', 'Last 30 days'|i18n( 'design/exp_doc' ) )}
<div class="template-design">
<div class="template-module content-view-full exp-doc-recent-classic">
<div class="template-object">

<div class="attribute-heading">
<h1>{'Recent ratings'|i18n( 'design/exp_doc' )}</h1>
</div>

<form class="exp-doc-recent-classic-filters" method="post" action={'doc/ratings'|ezurl}>
<p>
    <label for="exp-doc-ratings-manual">{'Manual'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-ratings-manual" name="Manual">
        <option value="">{'All manuals'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.manuals as $doc_manual}
        <option value="{$doc_manual.node_id}"{if and( is_set( $filters.manual ), eq( $filters.manual, $doc_manual.node_id ) )} selected="selected"{/if}>{$doc_manual.name|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-ratings-version">{'Version'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-ratings-version" name="Version">
        <option value="">{'All versions'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.versions as $doc_v}
        <option value="{$doc_v.node.node_id}"{if and( is_set( $filters.version ), eq( $filters.version, $doc_v.node.node_id ) )} selected="selected"{/if}>{$doc_v.manual.name|wash} {$doc_v.node.name|wash}</option>
    {/foreach}
    </select>
</p>
<p>
    <label for="exp-doc-ratings-range">{'Rated'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-ratings-range" name="Range">
    {foreach $doc_ranges as $doc_key => $doc_label}
        <option value="{$doc_key}"{if eq( first_set( $filters.range, 'all' ), $doc_key )} selected="selected"{/if}>{$doc_label|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-ratings-stars">{'At least'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-ratings-stars" name="Stars">
        <option value="">{'Any stars'|i18n( 'design/exp_doc' )}</option>
    {for 1 to 5 as $doc_n}
        <option value="{$doc_n}"{if and( is_set( $filters.stars ), eq( $filters.stars, $doc_n ) )} selected="selected"{/if}>{cond( eq( $doc_n, 1 ), '1 star'|i18n( 'design/exp_doc' ), '%n stars'|i18n( 'design/exp_doc', '', hash( '%n', $doc_n ) ) )}</option>
    {/for}
    </select>
    <label for="exp-doc-ratings-limit">{'Per page'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-ratings-limit" name="Limit">
    {foreach $limits as $doc_limit}
        <option value="{$doc_limit}"{if eq( $limit, $doc_limit )} selected="selected"{/if}>{$doc_limit}</option>
    {/foreach}
    </select>
    <input class="button" type="submit" name="FilterButton" value="{'Show'|i18n( 'design/exp_doc' )}" />
    {if $filters|count}<a href={$base_uri|ezurl}>{'Clear the filters'|i18n( 'design/exp_doc' )}</a>{/if}
</p>
</form>

<p>{'%count ratings'|i18n( 'design/exp_doc', '', hash( '%count', $count ) )} &middot; <a href={$feed_uri|ezurl}>{'Atom feed'|i18n( 'design/exp_doc' )}</a> &middot; <a href={$pages_uri|ezurl}>{'Recent changes'|i18n( 'design/exp_doc' )}</a></p>

{if $groups|count}
{foreach $groups as $doc_group}
<h2>{$doc_group.day|l10n( 'date' )}</h2>
<ul>
{foreach $doc_group.items as $doc_item}
{set-block variable=$doc_ago}{include uri='design:exp_doc/time_ago.tpl' time=$doc_item.time}{/set-block}
<li><div><a href={$doc_item.node.url_alias|ezurl}>{$doc_item.node.name|wash}</a>
    <br />{include uri='design:exp_doc/rating_stars.tpl' rating=hash( 'rating_average', $doc_item.stars, 'rating_count', 1 )} {'%age ago'|i18n( 'design/exp_doc', '', hash( '%age', $doc_ago|trim ) )} &middot; <span>{'The page now: %average of 5, %count ratings'|i18n( 'design/exp_doc', '', hash( '%average', $doc_item.average, '%count', $doc_item.count ) )}</span></div></li>
{/foreach}
</ul>
{/foreach}
{include uri='design:navigator/google.tpl' page_uri=$page_uri item_count=$count view_parameters=$view_parameters item_limit=$limit}
{else}
<p>{'No rating with these filters yet.'|i18n( 'design/exp_doc' )}</p>
{/if}

<div class="break"></div>
<hr class="hide" />

</div>
</div>
</div>
{undef $doc_ranges}
