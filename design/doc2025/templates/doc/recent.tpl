{* The recent changes (doc/recent) in the Classic design: a page the static site did not have, so a listed exception
   of the exactness check. It is drawn in the static pages' frame and classes (the full view's three boxes, the
   heading, plain lists), with the same filters, days, entries, pages and feed as the Modern view. Variables: see
   design/doc2026/templates/doc/recent.tpl. *}
{def $doc_types = hash( 'new', 'New'|i18n( 'design/exp_doc' ),
                        'updated', 'Updated'|i18n( 'design/exp_doc' ),
                        'history', 'Moved to history'|i18n( 'design/exp_doc' ) )
     $doc_ranges = hash( 'all', 'Any time'|i18n( 'design/exp_doc' ),
                         '24h', 'Last 24 hours'|i18n( 'design/exp_doc' ),
                         '7d', 'Last 7 days'|i18n( 'design/exp_doc' ),
                         '30d', 'Last 30 days'|i18n( 'design/exp_doc' ) )}
<div class="template-design">
<div class="template-module content-view-full exp-doc-recent-classic">
<div class="template-object">

<div class="attribute-heading">
<h1>{cond( eq( $mode, 'new' ), 'Recently added'|i18n( 'design/exp_doc' ), 'Recent changes'|i18n( 'design/exp_doc' ) )}</h1>
</div>

<form class="exp-doc-recent-classic-filters" method="post" action={concat( 'doc/', cond( eq( $mode, 'new' ), 'new', 'recent' ) )|ezurl}>
<p>
    <label for="exp-doc-recent-manual">{'Manual'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-recent-manual" name="Manual">
        <option value="">{'All manuals'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.manuals as $doc_manual}
        <option value="{$doc_manual.node_id}"{if and( is_set( $filters.manual ), eq( $filters.manual, $doc_manual.node_id ) )} selected="selected"{/if}>{$doc_manual.name|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-recent-version">{'Version'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-recent-version" name="Version">
        <option value="">{'All versions'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.versions as $doc_v}
        <option value="{$doc_v.node.node_id}"{if and( is_set( $filters.version ), eq( $filters.version, $doc_v.node.node_id ) )} selected="selected"{/if}>{$doc_v.manual.name|wash} {$doc_v.node.name|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-recent-class">{'Kind of page'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-recent-class" name="Class">
        <option value="">{'All kinds'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.classes as $doc_identifier => $doc_name}
        <option value="{$doc_identifier|wash}"{if and( is_set( $filters.class ), eq( $filters.class, $doc_identifier ) )} selected="selected"{/if}>{$doc_name|wash}</option>
    {/foreach}
    </select>
</p>
<p>
    <label for="exp-doc-recent-contributor">{'Last updated by'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-recent-contributor" name="Contributor">
        <option value="">{'Anyone'|i18n( 'design/exp_doc' )}</option>
    {foreach $options.contributors as $doc_person}
        <option value="{$doc_person.id}"{if and( is_set( $filters.contributor ), eq( $filters.contributor, $doc_person.id ) )} selected="selected"{/if}>{$doc_person.name|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-recent-range">{'Changed'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-recent-range" name="Range">
    {foreach $doc_ranges as $doc_key => $doc_label}
        <option value="{$doc_key}"{if eq( first_set( $filters.range, 'all' ), $doc_key )} selected="selected"{/if}>{$doc_label|wash}</option>
    {/foreach}
    </select>
    <label for="exp-doc-recent-limit">{'Per page'|i18n( 'design/exp_doc' )}</label>
    <select id="exp-doc-recent-limit" name="Limit">
    {foreach $limits as $doc_limit}
        <option value="{$doc_limit}"{if eq( $limit, $doc_limit )} selected="selected"{/if}>{$doc_limit}</option>
    {/foreach}
    </select>
    <input class="button" type="submit" name="FilterButton" value="{'Show'|i18n( 'design/exp_doc' )}" />
    {if $filters|count}<a href={$base_uri|ezurl}>{'Clear the filters'|i18n( 'design/exp_doc' )}</a>{/if}
</p>
</form>

<p>{cond( eq( $mode, 'new' ), '%count added pages'|i18n( 'design/exp_doc', '', hash( '%count', $count ) ), '%count changed pages'|i18n( 'design/exp_doc', '', hash( '%count', $count ) ) )} &middot; <a href={$feed_uri|ezurl}>{'Atom feed'|i18n( 'design/exp_doc' )}</a> &middot; <a href={ezini( 'RecentSettings', 'CommentsPath', 'exp_doc.ini' )|ezurl}>{'Recent comments'|i18n( 'design/exp_doc' )}</a> &middot; <a href={cond( eq( $mode, 'new' ), $changes_uri, $new_uri )|ezurl}>{cond( eq( $mode, 'new' ), 'Recent changes'|i18n( 'design/exp_doc' ), 'Recently added'|i18n( 'design/exp_doc' ) )}</a> &middot; <a href={ezini( 'RecentSettings', 'RatingsPath', 'exp_doc.ini' )|ezurl}>{'Recent ratings'|i18n( 'design/exp_doc' )}</a></p>

{if $groups|count}
{foreach $groups as $doc_group}
<h2>{$doc_group.day|l10n( 'date' )}</h2>
<ul>
{foreach $doc_group.items as $doc_item}
<li><div><a href={$doc_item.url|ezurl}>{$doc_item.title|wash}</a> ({$doc_types[$doc_item.type]|wash})
    <br />{if $doc_item.manual}{$doc_item.manual.name|wash}{/if}{if $doc_item.version} {$doc_item.version.name|wash}{/if}{if or( $doc_item.manual, $doc_item.version )} &middot; {/if}{if eq( $mode, 'new' )}{'Added %time'|i18n( 'design/exp_doc', '', hash( '%time', $doc_item.published|l10n( 'shorttime' ) ) )}{if $doc_item.author} &middot; {'Written by %name'|i18n( 'design/exp_doc', '', hash( '%name', concat( '<a href=', $doc_item.author.main_node.url_alias|ezurl, '>', $doc_item.author.name|wash, '</a>' ) ) )}{/if}{else}{'Changed %time'|i18n( 'design/exp_doc', '', hash( '%time', $doc_item.modified|l10n( 'shorttime' ) ) )}{/if}{if and( ne( $mode, 'new' ), $doc_item.by )} &middot; {if $doc_item.updated_at}{'Last updated by %name on %date'|i18n( 'design/exp_doc', '', hash( '%name', concat( '<a href=', $doc_item.by.main_node.url_alias|ezurl, '>', $doc_item.by.name|wash, '</a>' ), '%date', $doc_item.updated_at|l10n( 'shortdate' ) ) )}{else}{'Last updated by %name'|i18n( 'design/exp_doc', '', hash( '%name', concat( '<a href=', $doc_item.by.main_node.url_alias|ezurl, '>', $doc_item.by.name|wash, '</a>' ) ) )}{/if}{/if}
    {if $doc_item.excerpt}<br /><em>{$doc_item.excerpt|wash}</em>{/if}</div></li>
{/foreach}
</ul>
{/foreach}
{include uri='design:navigator/google.tpl' page_uri=$page_uri item_count=$count view_parameters=$view_parameters item_limit=$limit}
{else}
<p>{'No page has changed with these filters.'|i18n( 'design/exp_doc' )}</p>
{/if}

<div class="break"></div>
<hr class="hide" />

</div>
</div>
</div>
{undef $doc_types $doc_ranges}
