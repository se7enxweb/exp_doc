{* The landing page of the Modern design (the front page), in the help center's components and their color fades:
   - a large search in the hero (.a4-help-hero), its heading the official logo (named "Exponential" for screen
     readers) and exp_doc.ini [ModernSettings] LandingHeading;
   - "Who makes Exponential" (the help dashboard's exphelp/parts/dashboard_about.tpl), above the manuals;
   - a card for every manual (its cover or icon, summary and audience, and its versions), .a4-help-about and
     .a4-help-grow in turn, then one for the upgrade guides ([ModernSettings] UpgradeGuidesPath); the section centered;
   - "Choosing a product" (exp_doc/landing_choose.tpl): how the products differ and which one to take, the
     recommendation of Exponential 6 with its install button; on the front page only the products of [ChooseSettings]
     FrontProducts[] (Exponential and DXP), with the links to every choice (/choose) and every product (/products);
   - the products of [ModernSettings] FrontProductList[] (exp_doc/landing_products.tpl, fetch exp_doc/products: the
     containers once they exist, else [ModernSettings] ProductList[]) and the link to the page of every product,
     the same cards with the Supported badge where it applies;
   - right below the products, "Start where you are" (exp_doc/landing_start.tpl), the line to the help center's audiences;
   - the recently changed and added pages, comments, ratings, the help's recent Markdown changes and the latest
     commits of Exponential (exp_doc/help_recent_changes, help_commits), the Share forums' newest posts
     (exp_doc/forum_activity), and the most read pages (the kernel's view
     counts, no third-party tracker), each in an .a4-help-support box; the recently changed and added pages are one
     cache-block per role set (the lists only show what the reader may read): a query over every page each, they
     change only with a publish, which expires it (as do two hours);
   - last, below all of that, the help center's bottom blocks (exp_doc/landing_org.tpl: found an error, free
     documentation, Support Exponential). *}
{def $doc_manuals = fetch( 'content', 'tree', hash( 'parent_node_id', $node.node_id,
                                                     'class_filter_type', 'include', 'class_filter_array', array( 'exp_doc_manual' ),
                                                     'sort_by', array( 'priority', true() ), 'limit', 24 ) )
     $doc_popular = fetch( 'content', 'view_top_list', hash( 'limit', 8 ) )}
<section class="a4-help-hero exp-doc-hero" aria-labelledby="exp-doc-hero-title">
    <h1 id="exp-doc-hero-title" class="exp-doc-hero-title"><span class="exp-doc-hero-logo">{include uri='design:exp_doc/logo.tpl'}</span> {ezini( 'ModernSettings', 'LandingHeading', 'exp_doc.ini' )|wash}</h1>
    <p class="a4-help-hero-sub">{ezini( 'ModernSettings', 'LandingText', 'exp_doc.ini' )|wash}</p>
    <form class="exp-doc-hero-search" role="search" method="post" action={'content/search'|ezurl}>
        <label class="a4-sr-only" for="exp-doc-hero-search-text">{'Search the documentation'|i18n( 'design/exp_doc' )}</label>
        <input type="search" id="exp-doc-hero-search-text" name="SearchText" placeholder="{'What are you looking for?'|i18n( 'design/exp_doc' )}" autocomplete="off">
        <button type="submit" class="a4-btn a4-btn-primary" name="SearchButton">{'Search'|i18n( 'design/exp_doc' )}</button>
        {include uri='design:parts/front_search_suggest.tpl' suggest_id='exp-doc-hero-search-text'}
    </form>
    <p class="a4-meta exp-doc-hero-help">{'Guides, manuals and the reference of this Exponential installation, in English and German.'|i18n( 'design/exp_doc' )}</p>
    <p class="a4-help-hero-actions"><a class="a4-btn" href={'exphelp/dashboard'|ezurl}>{'Open the help center'|i18n( 'design/exp_doc' )}</a> <a class="a4-btn" href={'exphelp/contents'|ezurl}><span class="a4-icon a4-bi-list-ul" aria-hidden="true"></span> {'Browse all help'|i18n( 'design/exp_doc' )}</a></p>
</section>

{if fetch( 'exp_doc', 'help_report' )}
<div class="a4-help-frame exp-doc-landing-about">
    {include uri='design:exphelp/parts/dashboard_about.tpl' landing_on=ezini( 'LandingSettings', 'Enabled', 'exphelp.ini' )|eq( 'enabled' )}
</div>
{/if}

{if $doc_manuals|count}
<section class="exp-doc-landing-section exp-doc-landing-manuals" aria-labelledby="exp-doc-manuals-title">
    <h2 id="exp-doc-manuals-title" class="a4-h2">{'Exponential Developer Manuals'|i18n( 'design/exp_doc' )}</h2>
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
    {* the upgrade guides (exp_doc.ini [ModernSettings] UpgradeGuidesPath) as a third box of the same kind *}
    {if ezini( 'ModernSettings', 'UpgradeGuidesPath', 'exp_doc.ini' )|ne( '' )}
        <li class="a4-help-grow exp-doc-manual">
            <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon a4-bi-arrow-up-circle"></span></span>
            <div class="exp-doc-manual-body">
            <h3 class="exp-doc-manual-name"><a href={ezini( 'ModernSettings', 'UpgradeGuidesPath', 'exp_doc.ini' )|ezurl}>{'Upgrade guides'|i18n( 'design/exp_doc' )}</a></h3>
            <p class="exp-doc-manual-summary">{'Step by step from any earlier version to the current one, with the changes to the database and the settings.'|i18n( 'design/exp_doc' )}</p>
            </div>
        </li>
    {/if}
    </ul>
</section>
{/if}

{* "Choosing a product" (exp_doc/landing_choose.tpl, exp_doc.ini [ChooseSettings]), right before the products: only the
   products of [ChooseSettings] FrontProducts[], with the links to the page of every choice and of every product *}
{include uri='design:exp_doc/landing_choose.tpl' only=ezini( 'ChooseSettings', 'FrontProducts', 'exp_doc.ini' ) more=true()}

{* the products (exp_doc/landing_products.tpl: fetch exp_doc/products, [ModernSettings] ProductList[]): only those of
   [ModernSettings] FrontProductList[], with the link to the page of every product (ProductsPath); the same faded
   cards as the manuals *}
{include uri='design:exp_doc/landing_products.tpl' only=ezini( 'ModernSettings', 'FrontProductList', 'exp_doc.ini' ) more=true()}
{if fetch( 'exp_doc', 'help_report' )}{include uri='design:exp_doc/landing_start.tpl' framed=true()}{/if}

<div class="exp-doc-landing-columns">
{cache-block keys=array( fetch( 'user', 'current_user' ).role_id_list|implode( ',' ), fetch( 'user', 'current_user' ).limited_assignment_value_list|implode( ',' ) ) expiry=7200}{def $doc_recent = fetch( 'content', 'tree', hash( 'parent_node_id', $node.node_id,
                                                    'class_filter_type', 'include', 'class_filter_array', ezini( 'ModernSettings', 'PageClasses', 'exp_doc.ini' ),
                                                    'sort_by', array( 'modified', false() ), 'limit', 8 ) )}{if $doc_recent|count}
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
{undef $doc_recent $doc_added}{/cache-block}
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
{* the help's Markdown pages changed last (fetch exp_doc/help_recent_changes: the developers' help page's "Recently
   updated", in the reader's help language; the links keep /(lang)/<key>) *}
{def $doc_md = fetch( 'exp_doc', 'help_recent_changes', hash( 'limit', 8 ) )}
<section class="a4-help-support exp-doc-landing-section is-accent" aria-labelledby="exp-doc-markdown-title">
    <h2 id="exp-doc-markdown-title" class="a4-h2">{'Recent Markdown changes'|i18n( 'design/exp_doc' )}</h2>
    {if $doc_md|count}
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_md as $doc_item}
        <li><a href={$doc_item.url|ezurl}>{$doc_item.title|wash}</a>{if $doc_item.time|gt( 0 )} <span class="a4-meta"><time datetime="{$doc_item.time|datetime( 'custom', '%Y-%m-%dT%H:%i:%s' )}">{$doc_item.time|l10n( 'shortdate' )}</time></span>{/if}</li>
    {/foreach}
    </ol>
    {else}
    <p class="a4-meta">{'No changed help pages to show yet.'|i18n( 'design/exp_doc' )}</p>
    {/if}
    <p class="exp-doc-landing-more"><a href={'/exphelp/contents'|ezurl}>{'See all help pages'|i18n( 'design/exp_doc' )}</a></p>
</section>
{undef $doc_md}
{* the latest commits of se7enxweb/exponential without merges (fetch exp_doc/help_commits: the kernel's
   expHelpCommitFeed, read by the server with its timeout and cache; the browser loads nothing from outside) *}
{def $doc_commits = fetch( 'exp_doc', 'help_commits', hash( 'limit', 8 ) )}
{if $doc_commits}
<section class="a4-help-support exp-doc-landing-section" aria-labelledby="exp-doc-commits-title">
    <h2 id="exp-doc-commits-title" class="a4-h2">{'Recent commits'|i18n( 'design/exp_doc' )}</h2>
    {if $doc_commits.stale}
    <p class="a4-meta" role="status">{if $doc_commits.fetched|gt( 0 )}{'GitHub could not be reached just now. These are the commits read on %date.'|i18n( 'kernel/exphelp',, hash( '%date', $doc_commits.fetched|l10n( 'shortdatetime' ) ) )|wash}{else}{'The commits could not be read from GitHub. Open the history on GitHub instead.'|i18n( 'kernel/exphelp' )}{/if}</p>
    {/if}
    {if $doc_commits.commits|count}
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_commits.commits as $doc_c}
        <li>{$doc_c.title|shorten( 100 )|wash} <span class="a4-meta"><a href="{$doc_c.url|wash}" rel="noopener noreferrer"><code class="a4-code">{$doc_c.short|wash}</code></a>{if $doc_c.time|gt( 0 )} · <time datetime="{$doc_c.time|datetime( 'custom', '%Y-%m-%dT%H:%i:%s' )}">{$doc_c.time|l10n( 'shortdate' )}</time>{/if}</span></li>
    {/foreach}
    </ol>
    {elseif $doc_commits.stale|not}
    <p class="a4-meta">{'No commits to show yet.'|i18n( 'kernel/exphelp' )}</p>
    {/if}
    <p class="exp-doc-landing-more"><a href={$doc_commits.more|ezurl}>{'See all commits'|i18n( 'design/exp_doc' )}</a> · <a href="{$doc_commits.history|wash}" rel="noopener noreferrer">{'Full history on GitHub'|i18n( 'kernel/exphelp' )}</a></p>
</section>
{/if}
{undef $doc_commits}
{* the newest topics and replies of the Exponential Share forums (fetch exp_doc/forum_activity: expDocForumFeed, the
   forums' RSS feed read by the server with the commit feed's timeout and cache; exp_doc.ini [ModernSettings]
   ForumFeed*; the browser loads nothing from outside) *}
{def $doc_forum = fetch( 'exp_doc', 'forum_activity' )}
{if $doc_forum}
<section class="a4-help-support exp-doc-landing-section" aria-labelledby="exp-doc-forum-title">
    <h2 id="exp-doc-forum-title" class="a4-h2">{'Recent forum activity'|i18n( 'design/exp_doc' )}</h2>
    {if $doc_forum.stale}
    <p class="a4-meta" role="status">{if $doc_forum.fetched|gt( 0 )}{'The forums could not be reached just now. This is the activity read on %date.'|i18n( 'design/exp_doc',, hash( '%date', $doc_forum.fetched|l10n( 'shortdatetime' ) ) )|wash}{else}{'The forum activity could not be read. Open the forums instead.'|i18n( 'design/exp_doc' )}{/if}</p>
    {/if}
    {if $doc_forum.items|count}
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_forum.items as $doc_f}
        <li>{if $doc_f.reply}<span class="a4-tag">{'Reply'|i18n( 'design/exp_doc', 'forum post marker' )}</span> {/if}<a href="{$doc_f.url|wash}" rel="noopener noreferrer">{$doc_f.title|shorten( 100 )|wash}</a>{if or( $doc_f.author|ne( '' ), $doc_f.time|gt( 0 ) )} <span class="a4-meta">{$doc_f.author|wash}{if and( $doc_f.author|ne( '' ), $doc_f.time|gt( 0 ) )} · {/if}{if $doc_f.time|gt( 0 )}<time datetime="{$doc_f.time|datetime( 'custom', '%Y-%m-%dT%H:%i:%s' )}">{$doc_f.time|l10n( 'shortdate' )}</time>{/if}</span>{/if}</li>
    {/foreach}
    </ol>
    {elseif $doc_forum.stale|not}
    <p class="a4-meta">{'No forum activity to show yet.'|i18n( 'design/exp_doc' )}</p>
    {/if}
    <p class="exp-doc-landing-more"><a href="{$doc_forum.more|wash}" rel="noopener noreferrer">{'See all forum activity'|i18n( 'design/exp_doc' )}</a></p>
</section>
{/if}
{undef $doc_forum}
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
{include uri='design:exp_doc/landing_org.tpl' start=false() about=false()}
{undef $doc_manuals $doc_popular}
