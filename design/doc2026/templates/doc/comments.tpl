{* The recent comments (doc/comments, modules/doc/comments.php) in the Modern design: the filter form (it posts, the
   view redirects to the list with the filters as view parameters), the count, the feed and the link to the recent
   page changes, then the comments by day: each with its subject linked to the comment on its page, the commenter,
   the time, the page and the start of the text. Never a held comment. Variables: groups, count, offset, limit,
   limits, filters, options, page_uri, base_uri, pages_uri, feed_uri, view_parameters. *}
{def $doc_ranges = hash( 'all', 'Any time'|i18n( 'design/exp_doc' ),
                         '24h', 'Last 24 hours'|i18n( 'design/exp_doc' ),
                         '7d', 'Last 7 days'|i18n( 'design/exp_doc' ),
                         '30d', 'Last 30 days'|i18n( 'design/exp_doc' ) )}
<article class="exp-doc-article exp-doc-recent">
    <header class="exp-doc-recent-head">
        <h1 class="exp-doc-title">{'Recent comments'|i18n( 'design/exp_doc' )}</h1>
        <p class="exp-doc-recent-feed"><a class="a4-btn" href={$pages_uri|ezurl}>{'Recent changes'|i18n( 'design/exp_doc' )}</a> <a class="a4-btn" href={$feed_uri|ezurl}><span class="a4-icon a4-bi-rss" aria-hidden="true"></span> {'Atom feed'|i18n( 'design/exp_doc' )}</a></p>
    </header>

    <form class="a4-filterbar exp-doc-recent-filters" method="post" action={'doc/comments'|ezurl}>
        <div class="a4-field">
            <label for="exp-doc-comments-manual">{'Manual'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-comments-manual" name="Manual">
                <option value="">{'All manuals'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.manuals as $doc_manual}
                <option value="{$doc_manual.node_id}"{if and( is_set( $filters.manual ), eq( $filters.manual, $doc_manual.node_id ) )} selected{/if}>{$doc_manual.name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-comments-version">{'Version'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-comments-version" name="Version">
                <option value="">{'All versions'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.versions as $doc_v}
                <option value="{$doc_v.node.node_id}"{if and( is_set( $filters.version ), eq( $filters.version, $doc_v.node.node_id ) )} selected{/if}>{$doc_v.manual.name|wash} {$doc_v.node.name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-comments-range">{'Written'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-comments-range" name="Range">
            {foreach $doc_ranges as $doc_key => $doc_label}
                <option value="{$doc_key}"{if eq( first_set( $filters.range, 'all' ), $doc_key )} selected{/if}>{$doc_label|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-comments-type">{'Comments'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-comments-type" name="Type">
                <option value="readers"{if is_set( $filters.type )|not} selected{/if}>{'Readers’ comments'|i18n( 'design/exp_doc' )}</option>
                <option value="all"{if is_set( $filters.type )} selected{/if}>{'Readers’ and historical comments'|i18n( 'design/exp_doc' )}</option>
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-comments-limit">{'Per page'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-comments-limit" name="Limit">
            {foreach $limits as $doc_limit}
                <option value="{$doc_limit}"{if eq( $limit, $doc_limit )} selected{/if}>{$doc_limit}</option>
            {/foreach}
            </select>
        </div>
        <div class="exp-doc-recent-actions">
            <button type="submit" class="a4-btn a4-btn-primary" name="FilterButton">{'Show'|i18n( 'design/exp_doc' )}</button>
            {if $filters|count}<a class="a4-btn" href={$base_uri|ezurl}>{'Clear the filters'|i18n( 'design/exp_doc' )}</a>{/if}
        </div>
        <p class="a4-filter-count" role="status">{'%count comments'|i18n( 'design/exp_doc', '', hash( '%count', $count ) )}</p>
    </form>

{if $groups|count}
    {foreach $groups as $doc_group}
    <section class="exp-doc-recent-day" aria-labelledby="exp-doc-comments-{$doc_group.key|wash}">
        <h2 id="exp-doc-comments-{$doc_group.key|wash}" class="exp-doc-recent-date">{if $doc_group.day}{$doc_group.day|l10n( 'date' )}{else}{'Date unknown'|i18n( 'design/exp_doc' )}{/if}</h2>
        <ol class="a4-plain exp-doc-recent-list">
        {foreach $doc_group.items as $doc_item}
            <li class="a4-card exp-doc-recent-item">
                <h3 class="exp-doc-recent-title"><a href={concat( $doc_item.page.url_alias, '#', $doc_item.anchor )|ezurl}>{$doc_item.subject|wash}</a>{if eq( $doc_item.type, 'historical' )} <span class="a4-tag is-warn">{'Historical'|i18n( 'design/exp_doc' )}</span>{/if}</h3>
                <p class="a4-meta exp-doc-recent-meta">{$doc_item.name|wash}{if $doc_item.date} · {$doc_item.date|l10n( 'shortdatetime' )}{/if} · {'on %page'|i18n( 'design/exp_doc', '', hash( '%page', concat( '<a href=', $doc_item.page.url_alias|ezurl, '>', $doc_item.page.name|wash, '</a>' ) ) )}</p>
                {if $doc_item.excerpt}<p class="exp-doc-recent-excerpt">{$doc_item.excerpt|wash}</p>{/if}
            </li>
        {/foreach}
        </ol>
    </section>
    {/foreach}
    {include uri='design:navigator/google.tpl' page_uri=$page_uri item_count=$count view_parameters=$view_parameters item_limit=$limit}
{else}
    <p class="a4-card exp-doc-recent-empty">{'No comment with these filters yet.'|i18n( 'design/exp_doc' )}</p>
{/if}
</article>
{undef $doc_ranges}
