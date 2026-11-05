{* The Classic design (doc2025): the page frame of the static Exponential documentation site, element for element.
   The differences from the static pages are the modern exceptions the owner allowed:
   - HTTPS addresses only, and no inline scripts or styles (the static @import block and the onload handler are
     replaced by the packed stylesheets; the old menu and search scripts are not needed, see javascript/README);
   - the header switches (parts/switches.tpl): Classic / Modern and the content languages;
   - the viewport meta and the cookie banner;
   - no third-party trackers (the static gtag snippet is left out).
   Everything inside #page matches the static markup after whitespace normalization (the diff suite checks it). *}
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
{def $doc_node_id = $module_result.node_id
     $doc_is_front = false()}
{if and( is_set( $module_result.node_id ), eq( $module_result.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ),
         or( is_set( $module_result.content_info.viewmode )|not, eq( $module_result.content_info.viewmode, 'full' ) ) )}
    {set $doc_is_front = true()}
{/if}
<!DOCTYPE html>
<html lang="{$site.http_equiv.Content-language|wash}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
{if or( $doc_is_front, and( is_set( $module_result.left_menu ), $module_result.left_menu|contains( 'exphelp' ) ) )}
{* the help center's views (exphelp/*) and the front page (its help center blocks at the end, exp_doc/landing_org.tpl):
   the help center's components and styles, light, inside the Classic frame *}
{ezcss_load( array( 'core.css', 'classes.css', 'doc.css', 'ezdoc2024.css', 'components.css', 'exphelp.css', 'exp-doc-resizer.css', 'exp-doc-rating.css', 'doc2025.css' ) )}
{else}
{ezcss_load( array( 'core.css', 'classes.css', 'doc.css', 'ezdoc2024.css', 'exp-doc-rating.css', 'doc2025.css' ) )}
{/if}
<link type="text/css" rel="stylesheet" href={'stylesheets/print.css'|ezdesign} media="print" />
{include uri='design:parts/doc_head.tpl' path=$doc_path is_front=$doc_is_front}
</head>
<body>

<!-- Complete page area: START -->
<div id="page">

{include uri='design:parts/doc_header.tpl'}

<div id="page-content-position"><div id="page-content-position-inner"><div id="page-content">

{include uri='design:parts/doc_path.tpl' path=$doc_path}

<hr class="hide" />

<!-- Main area: START -->
{include uri='design:parts/doc_disclaimer.tpl'}

<div id="page-width5">
{def $doc_help = and( is_set( $module_result.left_menu ), $module_result.left_menu|contains( 'exphelp' ) )}
{* the help center's pages (not part of the static site): the menu is a resizable column, a drawer on a small screen
   (javascript/exp-doc-resizer.js, shared with Modern) *}
<div id="main" class="float-break{if $doc_help} exp-doc-resizable{/if}"{if $doc_help} data-exp-resizable="doc-classic-help" data-min="224" data-max="480"{/if}>
{if $doc_help}<button type="button" class="button exp-doc-drawer-toggle" data-exp-drawer-toggle aria-controls="exp-doc-side" aria-expanded="false" hidden>{'Menu'|i18n( 'design/exp_doc' )}</button>{/if}

{include uri='design:parts/doc_menu.tpl' path=$doc_path node_id=$doc_node_id resizable=$doc_help}
<div class="area-docmain-normal">
{if and( is_set( $module_result.left_menu ), $module_result.left_menu|contains( 'exphelp' ) )}<div class="a4-page exp-doc-help-classic">{$module_result.content}</div>{else}{$module_result.content}{/if}
</div>
<!-- Main area content: END -->

</div>
</div>
<!-- Main area: END -->
<hr class="hide" />

</div></div></div>

{include uri='design:parts/doc_footer.tpl'}

</div>
<!-- Complete page area: END -->

{include uri='design:exp_doc/cookie_consent.tpl'}
{include uri='design:parts/expwt_page_toolbar.tpl'}
{if $doc_help}<script type="module" src={'javascript/exp-doc-resizer.js'|ezdesign}></script>{/if}
<script type="module" src={'javascript/exp-doc-rating.js'|ezdesign}></script>
</body>
</html>
{undef $doc_root_id $doc_path $doc_seen $doc_node_id $doc_is_front $doc_help}
