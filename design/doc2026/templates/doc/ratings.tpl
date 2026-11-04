{* The recent ratings (doc/ratings, modules/doc/ratings.php) in the Modern design: the filter form (it posts, the view
   redirects to the list with the filters as view parameters), the count, the feed and the links to the other recent
   lists, then the ratings by day: each with its page linked, the stars given, how long ago, and the page's average and
   count now. Who rated is never shown. Variables: groups, count, offset, limit, limits, filters, options, page_uri,
   base_uri, pages_uri, feed_uri, view_parameters. *}
{def $doc_ranges = hash( 'all', 'Any time'|i18n( 'design/exp_doc' ),
                         '24h', 'Last 24 hours'|i18n( 'design/exp_doc' ),
                         '7d', 'Last 7 days'|i18n( 'design/exp_doc' ),
                         '30d', 'Last 30 days'|i18n( 'design/exp_doc' ) )}
<article class="exp-doc-article exp-doc-recent">
    <header class="exp-doc-recent-head">
        <h1 class="exp-doc-title">{'Recent ratings'|i18n( 'design/exp_doc' )}</h1>
        <p class="exp-doc-recent-feed"><a class="a4-btn" href={$pages_uri|ezurl}>{'Recent changes'|i18n( 'design/exp_doc' )}</a> <a class="a4-btn" href={$feed_uri|ezurl}><span class="a4-icon a4-bi-rss" aria-hidden="true"></span> {'Atom feed'|i18n( 'design/exp_doc' )}</a></p>
    </header>

    <form class="a4-filterbar exp-doc-recent-filters" method="post" action={'doc/ratings'|ezurl}>
        <div class="a4-field">
            <label for="exp-doc-ratings-manual">{'Manual'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-ratings-manual" name="Manual">
                <option value="">{'All manuals'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.manuals as $doc_manual}
                <option value="{$doc_manual.node_id}"{if and( is_set( $filters.manual ), eq( $filters.manual, $doc_manual.node_id ) )} selected{/if}>{$doc_manual.name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-ratings-version">{'Version'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-ratings-version" name="Version">
                <option value="">{'All versions'|i18n( 'design/exp_doc' )}</option>
            {foreach $options.versions as $doc_v}
                <option value="{$doc_v.node.node_id}"{if and( is_set( $filters.version ), eq( $filters.version, $doc_v.node.node_id ) )} selected{/if}>{$doc_v.manual.name|wash} {$doc_v.node.name|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-ratings-range">{'Rated'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-ratings-range" name="Range">
            {foreach $doc_ranges as $doc_key => $doc_label}
                <option value="{$doc_key}"{if eq( first_set( $filters.range, 'all' ), $doc_key )} selected{/if}>{$doc_label|wash}</option>
            {/foreach}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-ratings-stars">{'At least'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-ratings-stars" name="Stars">
                <option value="">{'Any stars'|i18n( 'design/exp_doc' )}</option>
            {for 1 to 5 as $doc_n}
                <option value="{$doc_n}"{if and( is_set( $filters.stars ), eq( $filters.stars, $doc_n ) )} selected{/if}>{cond( eq( $doc_n, 1 ), '1 star'|i18n( 'design/exp_doc' ), '%n stars'|i18n( 'design/exp_doc', '', hash( '%n', $doc_n ) ) )}</option>
            {/for}
            </select>
        </div>
        <div class="a4-field">
            <label for="exp-doc-ratings-limit">{'Per page'|i18n( 'design/exp_doc' )}</label>
            <select id="exp-doc-ratings-limit" name="Limit">
            {foreach $limits as $doc_limit}
                <option value="{$doc_limit}"{if eq( $limit, $doc_limit )} selected{/if}>{$doc_limit}</option>
            {/foreach}
            </select>
        </div>
        <div class="exp-doc-recent-actions">
            <button type="submit" class="a4-btn is-primary" name="FilterButton">{'Show'|i18n( 'design/exp_doc' )}</button>
            {if $filters|count}<a class="a4-btn" href={$base_uri|ezurl}>{'Clear the filters'|i18n( 'design/exp_doc' )}</a>{/if}
        </div>
        <p class="a4-filter-count" role="status">{'%count ratings'|i18n( 'design/exp_doc', '', hash( '%count', $count ) )}</p>
    </form>

{if $groups|count}
    {foreach $groups as $doc_group}
    <section class="exp-doc-recent-day" aria-labelledby="exp-doc-ratings-{$doc_group.key|wash}">
        <h2 id="exp-doc-ratings-{$doc_group.key|wash}" class="exp-doc-recent-date">{$doc_group.day|l10n( 'date' )}</h2>
        <ol class="a4-plain exp-doc-recent-list">
        {foreach $doc_group.items as $doc_item}
            {set-block variable=$doc_ago}{include uri='design:exp_doc/time_ago.tpl' time=$doc_item.time}{/set-block}
            <li class="a4-card exp-doc-recent-item">
                <h3 class="exp-doc-recent-title"><a href={$doc_item.node.url_alias|ezurl}>{$doc_item.node.name|wash}</a></h3>
                <p class="a4-meta exp-doc-recent-meta">{include uri='design:exp_doc/rating_stars.tpl' rating=hash( 'rating_average', $doc_item.stars, 'rating_count', 1 )} {'%age ago'|i18n( 'design/exp_doc', '', hash( '%age', $doc_ago|trim ) )} · <span>{'The page now: %average of 5, %count ratings'|i18n( 'design/exp_doc', '', hash( '%average', $doc_item.average, '%count', $doc_item.count ) )}</span></p>
            </li>
        {/foreach}
        </ol>
    </section>
    {/foreach}
    {include uri='design:navigator/google.tpl' page_uri=$page_uri item_count=$count view_parameters=$view_parameters item_limit=$limit}
{else}
    <p class="a4-card exp-doc-recent-empty">{'No rating with these filters yet.'|i18n( 'design/exp_doc' )}</p>
{/if}
</article>
{undef $doc_ranges}
