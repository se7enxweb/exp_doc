{* The recent comments (doc/comments) in the Classic design: a page the static site did not have, so a listed
   exception of the exactness check, drawn in the static pages' frame and classes, with the same filters, days,
   entries, pages and feed as the Modern view. Variables: see design/doc2026/templates/doc/comments.tpl. *}
{def $doc_ranges = hash( 'all', 'Any time'|i18n( 'design/exp_doc' ),
                         '24h', 'Last 24 hours'|i18n( 'design/exp_doc' ),
                         '7d', 'Last 7 days'|i18n( 'design/exp_doc' ),
                         '30d', 'Last 30 days'|i18n( 'design/exp_doc' ) )}
<div class="template-design">
<div class="template-module content-view-full exp-doc-recent-classic">
<div class="template-object">

<div class="attribute-heading">
<h1>{'Recent comments'|i18n( 'design/exp_doc' )}</h1>
</div>

<form class="exp-doc-recent-classic-filters" method="post" action={'doc/comments'|ezurl}>
<p>
    <label for="exp-doc-comments-manual">{'Manual'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-comments-manual" name="Manual">
        <option value="">{'All manuals'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.manuals as $doc_manual}
        <option value="{$doc_manual.node_id}"{if and( is_set( $filters.manual ), eq( $filters.manual, $doc_manual.node_id ) )} selected="selected"{/if}>{$doc_manual.name|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-comments-version">{'Version'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-comments-version" name="Version">
        <option value="">{'All versions'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.versions as $doc_v}
        <option value="{$doc_v.node.node_id}"{if and( is_set( $filters.version ), eq( $filters.version, $doc_v.node.node_id ) )} selected="selected"{/if}>{$doc_v.manual.name|wash} {$doc_v.node.name|wash}</option>
    {/foreach}
    </select>
</p>
<p>
    <label for="exp-doc-comments-range">{'Written'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-comments-range" name="Range">
    {foreach $doc_ranges as $doc_key => $doc_label}
        <option value="{$doc_key}"{if eq( first_set( $filters.range, 'all' ), $doc_key )} selected="selected"{/if}>{$doc_label|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-comments-type">{'Comments'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-comments-type" name="Type">
        <option value="readers"{if is_set( $filters.type )|not} selected="selected"{/if}>{'Readers’ comments'|i18n( 'design/exp_doc' )}</option>
        <option value="all"{if is_set( $filters.type )} selected="selected"{/if}>{'Readers’ and historical comments'|i18n( 'design/exp_doc' )}</option>
    </select>
    <label for="exp-doc-comments-limit">{'Per page'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-comments-limit" name="Limit">
    {foreach $limits as $doc_limit}
        <option value="{$doc_limit}"{if eq( $limit, $doc_limit )} selected="selected"{/if}>{$doc_limit}</option>
    {/foreach}
    </select>
    <input class="button" type="submit" name="FilterButton" value="{'Show'|i18n( 'design/exp_doc' )}" />
    {if $filters|count}<a href={$base_uri|ezurl}>{'Clear the filters'|i18n( 'design/exp_doc' )}</a>{/if}
</p>
</form>

<p>{'%count comments'|i18n( 'design/exp_doc', '', hash( '%count', $count ) )} &middot; <a href={$feed_uri|ezurl}>{'Atom feed'|i18n( 'design/exp_doc' )}</a> &middot; <a href={$pages_uri|ezurl}>{'Recent changes'|i18n( 'design/exp_doc' )}</a></p>

{if $groups|count}
{foreach $groups as $doc_group}
<h2>{if $doc_group.day}{$doc_group.day|l10n( 'date' )}{else}{'Date unknown'|i18n( 'design/exp_doc' )}{/if}</h2>
<ul>
{foreach $doc_group.items as $doc_item}
<li><div><a href={concat( $doc_item.page.url_alias, '#', $doc_item.anchor )|ezurl}>{$doc_item.subject|wash}</a>{if eq( $doc_item.type, 'historical' )} ({'Historical'|i18n( 'design/exp_doc' )}){/if}
    <br />{$doc_item.name|wash}{if $doc_item.date} &middot; {$doc_item.date|l10n( 'shortdatetime' )}{/if} &middot; {'on %page'|i18n( 'design/exp_doc', '', hash( '%page', concat( '<a href=', $doc_item.page.url_alias|ezurl, '>', $doc_item.page.name|wash, '</a>' ) ) )}
    {if $doc_item.excerpt}<br /><em>{$doc_item.excerpt|wash}</em>{/if}</div></li>
{/foreach}
</ul>
{/foreach}
{include uri='design:navigator/google.tpl' page_uri=$page_uri item_count=$count view_parameters=$view_parameters item_limit=$limit}
{else}
<p>{'No comment with these filters yet.'|i18n( 'design/exp_doc' )}</p>
{/if}

<div class="break"></div>
<hr class="hide" />

</div>
</div>
</div>
{undef $doc_ranges}
