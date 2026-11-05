{* The page panel of a Confluence page in the Classic design (the full view, parts/doc_full.tpl, for a node of
   fetch exp_doc/confluence_context; the frame around it is parts/confluence_frame.tpl), as the static Atlassian page
   had it:
   - the header: the "..." menu (the page's attachments, its place in the space's page list), the space logo, the
     breadcrumbs (the space linking its home page, then the pages down to the parent; with more than two, the ones
     between the first and the last are folded into "…", as Confluence did) and the title without the static suffix;
   - the byline (parts/doc_confluence_meta.tpl), with the paperclip when the page has attachments;
   - the body, the labels (the page's tags, or "No labels"), the Classic additions every page has (the contributors and
     the rating, both listed exceptions of the check), and the historical comments (parts/doc_comments.tpl, in
     Confluence's markup). Parameters: node, context. *}
{def $cf = $context
     $cf_map = $node.data_map
     $cf_count = $cf.crumbs|count
     $cf_link = cond( $cf.home, $cf.home, $cf.space )}
<div id="main" class="aui-page-panel">
    <div id="main-header">
        <div id="navigation" class="content-navigation view">
            <ul class="ajs-menu-bar">
                <li class="normal ajs-menu-item">
                    <details class="exp-doc-cf-actions">
                        <summary id="action-menu-link" class="action aui-button aui-button-subtle ajs-menu-title" title="{'More actions'|i18n( 'design/doc2025' )}"><span class="aui-icon aui-icon-small aui-iconfont-more">{'More actions'|i18n( 'design/doc2025' )}</span></summary>
                        <div id="action-menu" class="aui-dropdown2 aui-style-default">
                            <ul id="action-menu-primary" class="section-primary first aui-dropdown2-section">
                                <li><span id="view-attachments-link" class="action-view-attachments">{'Attachments (%count)'|i18n( 'design/doc2025', '', hash( '%count', $cf.attachments|count ) )}</span>
{if $cf.attachments|count}
                                    <ul class="exp-doc-cf-attachments">
{foreach $cf.attachments as $cf_file}
                                        <li><a href={$cf_file.main_node.url_alias|ezurl}>{$cf_file.name|wash}</a></li>
{/foreach}
                                    </ul>
{/if}
                                </li>
                            </ul>
                            <ul id="action-menu-secondary" class="section-secondary aui-dropdown2-section">
                                <li><a id="view-in-hierarchy-link" href={concat( 'content/view/sitemap/', cond( $cf.space, $cf.space.node_id, $node.node_id ) )|ezurl}>{'View in Hierarchy'|i18n( 'design/doc2025' )}</a></li>
                            </ul>
                        </div>
                    </details>
                </li>
            </ul>
        </div>
        <div id="title-heading" class="pagetitle with-breadcrumbs">
            <div class="space-logo">
                <a href={cond( $cf_link, $cf_link.url_alias, $node.url_alias )|ezurl}><img class="logo global custom" src={'images/confluence/space-logo.png'|ezdesign} alt="" width="48" height="48" /></a>
            </div>
            <div id="breadcrumb-section">
                <ol id="breadcrumbs">
{if $cf.space}
                    <li class="first"><span><a href={cond( $cf_link, $cf_link.url_alias, $node.url_alias )|ezurl}>{$cf.name|wash}</a></span></li>
{/if}
{if $cf_count|gt( 2 )}
                    <li id="ellipsis" title="{'Show all breadcrumbs'|i18n( 'design/doc2025' )}"><span><strong>&#8230;</strong></span></li>
{/if}
{foreach $cf.crumbs as $cf_index => $cf_crumb}
                    <li{if and( $cf_count|gt( 2 ), $cf_index|lt( dec( $cf_count ) ) )} class="hidden-crumb"{/if}><span><a href={$cf_crumb.node.url_alias|ezurl}>{$cf_crumb.title|wash}</a></span></li>
{/foreach}
                </ol>
            </div>
            <h1 id="title-text" class="with-breadcrumbs"><a href={$node.url_alias|ezurl}>{$cf.title|wash}</a></h1>
        </div>
    </div>
    <div id="content" class="page view">
        <div id="action-messages"></div>
{include uri='design:parts/doc_confluence_meta.tpl' node=$node attachments=$cf.attachments|count}
        <div id="main-content" class="wiki-content">
{$body_html}
        </div>
        <div id="likes-and-labels-container">
            <div id="likes-section"></div>
            <div id="labels-section" class="pageSection group">
                <div class="labels-section-content content-column">
                    <div class="labels-content">
                        <ul class="label-list label-list-right">
{if and( is_set( $cf_map.labels ), $cf_map.labels.has_content, $cf_map.labels.content.tags|count )}
{foreach $cf_map.labels.content.tags as $cf_tag}
                            <li class="aui-label"><a class="aui-label-split-main" href={$cf_tag.url|ezurl} rel="tag">{$cf_tag.keyword|wash}</a></li>
{/foreach}
{else}
                            <li class="no-labels-message">{'No labels'|i18n( 'design/doc2025' )}</li>
{/if}
                        </ul>
                    </div>
                </div>
            </div>
        </div>
{include uri='design:parts/doc_contributors.tpl' node=$node}
{include uri='design:exp_doc/rating_form.tpl' node=$node}
{include uri='design:parts/doc_comments.tpl' node=$node}
    </div>
</div>
{undef $cf $cf_map $cf_count $cf_link}
