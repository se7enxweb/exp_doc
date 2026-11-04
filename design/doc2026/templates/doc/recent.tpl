{* The recent changes (doc/recent, modules/doc/recent.php) in the Modern design: the filter form (it posts, the view
   redirects to the list with the filters as view parameters), the count and the feed link, the entries by day (each
   with its title, the change, manual and version, who last updated it and when, and the start of its body), and the
   pages. Variables: groups, count, offset, limit, limits, default_limit, filters, options, page_uri, base_uri,
   feed_uri, view_parameters. *}
{def $doc_types = hash( 'new', 'New'|i18n( 'design/exp_doc' ),
                        'updated', 'Updated'|i18n( 'design/exp_doc' ),
                        'history', 'Moved to history'|i18n( 'design/exp_doc' ) )
     $doc_tones = hash( 'new', 'is-ok', 'updated', 'is-info', 'history', 'is-warn' )
     $doc_ranges = hash( 'all', 'Any time'|i18n( 'design/exp_doc' ),
                         '24h', 'Last 24 hours'|i18n( 'design/exp_doc' ),
                         '7d', 'Last 7 days'|i18n( 'design/exp_doc' ),
                         '30d', 'Last 30 days'|i18n( 'design/exp_doc' ) )}
<article class="exp-doc-article exp-doc-recent">
    <header class="exp-doc-recent-head">
        <h1 class="exp-doc-title">{'Recent changes'|i18n( 'design/exp_doc' )}</h1>
        <p class="exp-doc-recent-feed"><a class="a4-btn" href={$feed_uri|ezurl}><span class="a4-icon a4-bi-rss" aria-hidden="true"></span> {'Atom feed'|i18n( 'design/exp_doc' )}</a></p>
    </header>

    <form class="a4-filterbar exp-doc-recent-filters" method="post" action={'doc/recent'|ezurl}>
        <div class="a4-field">
            <label for="exp-doc-recent-manual">{'Manual'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-recent-manual" name="Manual">
                <option value="">{'All manuals'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.manuals as $doc_manual}
                <option value="{$doc_manual.node_id}"{if and( is_set( $filters.manual ), eq( $filters.manual, $doc_manual.node_id ) )} selected{/if}>{$doc_manual.name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-recent-version">{'Version'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-recent-version" name="Version">
                <option value="">{'All versions'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.versions as $doc_v}
                <option value="{$doc_v.node.node_id}"{if and( is_set( $filters.version ), eq( $filters.version, $doc_v.node.node_id ) )} selected{/if}>{$doc_v.manual.name|wash} {$doc_v.node.name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-recent-class">{'Kind of page'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-recent-class" name="Class">
                <option value="">{'All kinds'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.classes as $doc_identifier => $doc_name}
                <option value="{$doc_identifier|wash}"{if and( is_set( $filters.class ), eq( $filters.class, $doc_identifier ) )} selected{/if}>{$doc_name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-recent-contributor">{'Last updated by'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-recent-contributor" name="Contributor">
                <option value="">{'Anyone'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.contributors as $doc_person}
                <option value="{$doc_person.id}"{if and( is_set( $filters.contributor ), eq( $filters.contributor, $doc_person.id ) )} selected{/if}>{$doc_person.name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-recent-range">{'Changed'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-recent-range" name="Range">
            {foreach $doc_ranges as $doc_key => $doc_label}
                <option value="{$doc_key}"{if eq( first_set( $filters.range, 'all' ), $doc_key )} selected{/if}>{$doc_label|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-recent-limit">{'Per page'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-recent-limit" name="Limit">
            {foreach $limits as $doc_limit}
                <option value="{$doc_limit}"{if eq( $limit, $doc_limit )} selected{/if}>{$doc_limit}</option>
            {/foreach}
            </select>
        </div>
        <div class="exp-doc-recent-actions">
            <button type="submit" class="a4-btn is-primary" name="FilterButton">{'Show'|i18n( 'design/exp_doc' )}</button>
            {if $filters|count}<a class="a4-btn" href={$base_uri|ezurl}>{'Clear the filters'|i18n( 'design/exp_doc' )}</a>{/if}
        </div>
        <p class="a4-filter-count" role="status">{'%count changed pages'|i18n( 'design/exp_doc', '', hash( '%count', $count ) )}</p>
    </form>

{if $groups|count}
    {foreach $groups as $doc_group}
    <section class="exp-doc-recent-day" aria-labelledby="exp-doc-recent-{$doc_group.key|wash}">
        <h2 id="exp-doc-recent-{$doc_group.key|wash}" class="exp-doc-recent-date">{$doc_group.day|l10n( 'date' )}</h2>
        <ol class="a4-plain exp-doc-recent-list">
        {foreach $doc_group.items as $doc_item}
            <li class="a4-card exp-doc-recent-item">
                <h3 class="exp-doc-recent-title"><a href={$doc_item.url|ezurl}>{$doc_item.title|wash}</a> <span class="a4-tag {$doc_tones[$doc_item.type]}">{$doc_types[$doc_item.type]|wash}</span></h3>
                <p class="a4-meta exp-doc-recent-meta">
                    {if $doc_item.manual}<a href={$doc_item.manual.url_alias|ezurl}>{$doc_item.manual.name|wash}</a>{/if}{if $doc_item.version} · <a href={$doc_item.version.url_alias|ezurl}>{$doc_item.version.name|wash}</a>{/if}
                    {if or( $doc_item.manual, $doc_item.version )} · {/if}{'Changed %time'|i18n( 'design/exp_doc', '', hash( '%time', $doc_item.modified|l10n( 'shorttime' ) ) )}
                    {if $doc_item.by} · {if $doc_item.updated_at}{'Last updated by %name on %date'|i18n( 'design/exp_doc', '', hash( '%name', concat( '<a href=', $doc_item.by.main_node.url_alias|ezurl, '>', $doc_item.by.name|wash, '</a>' ), '%date', $doc_item.updated_at|l10n( 'shortdate' ) ) )}{else}{'Last updated by %name'|i18n( 'design/exp_doc', '', hash( '%name', concat( '<a href=', $doc_item.by.main_node.url_alias|ezurl, '>', $doc_item.by.name|wash, '</a>' ) ) )}{/if}{/if}
                </p>
                {if $doc_item.excerpt}<p class="exp-doc-recent-excerpt">{$doc_item.excerpt|wash}</p>{/if}
            </li>
        {/foreach}
        </ol>
    </section>
    {/foreach}
    {include uri='design:navigator/google.tpl' page_uri=$page_uri item_count=$count view_parameters=$view_parameters item_limit=$limit}
{else}
    <p class="a4-card exp-doc-recent-empty">{'No page has changed with these filters.'|i18n( 'design/exp_doc' )}</p>
{/if}
</article>
{undef $doc_types $doc_tones $doc_ranges}
