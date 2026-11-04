{* The Modern design (doc2026, the "doc" design): the Exponential brand on the help center's tokens and components
   (components.css, copied from admin4), light and dark. A docs layout in three columns: the page tree on the left,
   the page in the middle, the page's own contents on the right (sticky), one column on a phone with the tree in a
   drawer. No inline scripts or styles: the color mode is set by javascript/doc2026-theme.js in the head, everything
   else by javascript/doc2026.js at the end. The front page draws its landing page (parts/doc_landing.tpl) instead of
   the three columns. *}
{* the path from the site's root (content.ini [NodeSettings] RootNode) down; the folders above it (the multisite
   tree's "Websites") are not part of this site *}
{def $doc_root_id = ezini( 'NodeSettings', 'RootNode', 'content.ini' )
     $doc_path = array()
     $doc_seen = false()}
{foreach $module_result.path as $doc_item}
    {if and( is_set( $doc_item.node_id ), eq( $doc_item.node_id, $doc_root_id ) )}{set $doc_seen = true()}{/if}
    {if $doc_seen}{set $doc_path = $doc_path|append( $doc_item )}{/if}
{/foreach}
{if not( $doc_seen )}{set $doc_path = $module_result.path}{/if}
{def $doc_node = cond( and( is_set( $module_result.node_id ), $module_result.node_id ),
                       fetch( 'content', 'node', hash( 'node_id', $module_result.node_id ) ), false() )
     $doc_is_front = and( $doc_node, eq( $doc_node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ) )}
<!DOCTYPE html>
<html lang="{$site.http_equiv.Content-language|wash}" class="exp-doc-modern">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light dark">
{ezscript_load( array( 'doc2026-theme.js' ) )}
{ezcss_load( array( 'components.css', 'doc2026.css' ) )}
<link rel="stylesheet" href={'stylesheets/doc2026-print.css'|ezdesign} media="print">
{include uri='design:parts/doc_head.tpl' path=$doc_path node=$doc_node is_front=$doc_is_front}
</head>
<body class="a4-page exp-doc{if $doc_is_front} exp-doc-is-front{/if}">
<a class="a4-skip-link" href="#exp-doc-main">{'Skip to the content'|i18n( 'design/exp_doc' )}</a>

{include uri='design:parts/doc_header.tpl' node=$doc_node}

{if $doc_is_front}
<main id="exp-doc-main" class="exp-doc-main exp-doc-main-front" tabindex="-1">
{$module_result.content}
</main>
{else}
<div class="exp-doc-frame">
    {include uri='design:parts/doc_tree.tpl' node=$doc_node path=$doc_path}
    <main id="exp-doc-main" class="exp-doc-main" tabindex="-1">
        {include uri='design:parts/doc_crumbs.tpl' path=$doc_path}
        {$module_result.content}
    </main>
    <aside class="exp-doc-onpage" aria-labelledby="exp-doc-onpage-title">
        <div class="exp-doc-onpage-inner" data-exp-doc-onpage>
            <h2 id="exp-doc-onpage-title" class="exp-doc-onpage-title">{'On this page'|i18n( 'design/exp_doc' )}</h2>
            <nav aria-labelledby="exp-doc-onpage-title"><ol class="exp-doc-onpage-list" data-exp-doc-onpage-list></ol></nav>
        </div>
    </aside>
</div>
{/if}

{include uri='design:parts/doc_footer.tpl'}

{include uri='design:exp_doc/cookie_consent.tpl'}
{include uri='design:parts/expwt_page_toolbar.tpl'}
<script type="application/json" id="exp-doc-strings">{json_encode( hash( 'copy', 'Copy'|i18n( 'design/exp_doc' ), 'copied', 'Copied'|i18n( 'design/exp_doc' ), 'copyLink', 'Copy the link to this heading'|i18n( 'design/exp_doc' ), 'themeSystem', 'System'|i18n( 'design/exp_doc' ), 'themeLight', 'Light'|i18n( 'design/exp_doc' ), 'themeDark', 'Dark'|i18n( 'design/exp_doc' ) ) )}</script>
{ezscript_load( array( 'doc2026.js' ) )}
</body>
</html>
{undef $doc_root_id $doc_path $doc_seen $doc_node $doc_is_front}
