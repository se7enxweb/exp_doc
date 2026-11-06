{* The Classic design (doc2025): the page frame of the static Exponential documentation site, element for element.
   The differences from the static pages are the modern exceptions the owner allowed:
   - HTTPS addresses only, and no inline scripts or styles (the static @import block and the onload handler are
     replaced by the packed stylesheets; the old menu and search scripts are not needed, see javascript/README);
   - the header switches (parts/switches.tpl): Classic / Modern and the content languages;
   - the viewport meta and the cookie banner;
   - the static gtag snippet's place is taken by exp_doc/analytics.tpl: the website statistics tag of
     bcwebsitestatistics.ini, loaded only after the reader accepts statistics in the cookie banner.
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
{* a product's container (fetch exp_doc/is_product): its box after the heading uses the help center's components *}
{def $doc_is_product = false()}
{if and( $doc_is_front|not, is_set( $module_result.node_id ), $module_result.node_id,
         or( is_set( $module_result.content_info.viewmode )|not, eq( $module_result.content_info.viewmode, 'full' ) ) )}
    {set $doc_is_product = fetch( 'exp_doc', 'is_product', hash( 'node_id', $module_result.node_id ) )}
{/if}
{* a page of exp_doc.ini [PageDisplaySettings] (every product, every choice): its list uses the help center's
   components *}
{def $doc_is_display = false()
     $doc_displays = ezini( 'PageDisplaySettings', 'Display', 'exp_doc.ini' )}
{if and( $doc_is_front|not, is_set( $module_result.content_info.remote_id ) )}
    {if is_set( $doc_displays[$module_result.content_info.remote_id] )}{set $doc_is_display = true()}{/if}
{/if}
{* a help topic, manual or chapter (help_*: help maintained as content): its text as the help renders it
   (full/exp_doc_help_topic.tpl), which the help center's styles draw (heading anchors, code, figures) *}
{def $doc_is_help = and( is_set( $module_result.content_info.class_identifier ),
                         $module_result.content_info.class_identifier|begins_with( 'help_' ) )}
{* a page of the former documentation center's Confluence spaces (fetch exp_doc/confluence_context): the static site's
   Atlassian frame (parts/confluence_frame.tpl) and its stylesheet instead of the ezdoc frame *}
{def $doc_confluence = false()}
{if and( $doc_is_front|not, is_set( $module_result.node_id ), $module_result.node_id,
         or( is_set( $module_result.content_info.viewmode )|not, eq( $module_result.content_info.viewmode, 'full' ) ) )}
    {set $doc_confluence = fetch( 'exp_doc', 'confluence_context', hash( 'node_id', $module_result.node_id ) )}
{/if}
<!DOCTYPE html>
{* data-a4-modes="light": Classic has no dark mode, so the help center components it shows (the front page's frames,
   the rating form, the exphelp views) keep their light tokens even where html[data-a4-theme="dark"] is set
   (components.css) *}
<html lang="{$site.http_equiv.Content-language|wash}" data-a4-modes="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
{if $doc_confluence}
{* the Confluence frame: its own stylesheet (the static Atlassian frame's look), the rating's and the Classic additions'
   (the header switches, the collapsed comments) *}
{ezcss_load( array( 'exp-doc-rating.css', 'doc2025.css', 'doc2025-confluence.css' ) )}
{elseif or( $doc_is_front, $doc_is_product, $doc_is_display, $doc_is_help, and( is_set( $module_result.left_menu ), $module_result.left_menu|contains( 'exphelp' ) ) )}
{* the help center's views (exphelp/*) and the front page (its help center blocks at the end, exp_doc/landing_org.tpl):
   the help center's components and styles, light, inside the Classic frame *}
{ezcss_load( array( 'core.css', 'classes.css', 'doc.css', 'ezdoc2024.css', 'components.css', 'exphelp.css', 'exp-doc-choose.css', 'exp-doc-resizer.css', 'exp-doc-rating.css', 'doc2025.css' ) )}
{else}
{ezcss_load( array( 'core.css', 'classes.css', 'doc.css', 'ezdoc2024.css', 'exp-doc-rating.css', 'doc2025.css' ) )}
{/if}
<link type="text/css" rel="stylesheet" href={'stylesheets/print.css'|ezdesign} media="print" />
{if $doc_confluence}
{include uri='design:parts/doc_head.tpl' path=$doc_path is_front=$doc_is_front title=$doc_path|reverse|extract_left( 1 )[0].text}
{else}
{include uri='design:parts/doc_head.tpl' path=$doc_path is_front=$doc_is_front}
{/if}
</head>
{if $doc_confluence}
<body id="com-atlassian-confluence" class="theme-documentation aui-layout aui-theme-default exp-doc-confluence">
{def $doc_help = false()}
{include uri='design:parts/confluence_frame.tpl' context=$doc_confluence node_id=$doc_node_id}
{else}
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
{def $doc_help = and( is_set( $module_result.left_menu ), $module_result.left_menu|contains( 'exphelp' ) )
     $doc_side_open = eq( ezpreference( 'exp_doc_help_sidebar' ), 'expanded' )}
{* the help center's pages (not part of the static site): the menu is a resizable column, a drawer on a small screen
   (javascript/exp-doc-resizer.js, shared with Modern), and can be hidden to a slim rail (design:exp_doc/side_toggle.tpl):
   hidden unless the reader's preference says expanded, drawn so from the start *}
<div id="main" class="float-break{if $doc_help} exp-doc-resizable has-side-toggle{if not( $doc_side_open )} is-side-collapsed{/if}{/if}"{if $doc_help} data-exp-resizable="doc-classic-help" data-min="224" data-max="480" data-exp-side-pref="{ezpreference( 'exp_doc_help_sidebar' )|wash}"{/if}>
{if $doc_help}<button type="button" class="button exp-doc-drawer-toggle" data-exp-drawer-toggle aria-controls="exp-doc-side" aria-expanded="false" hidden>{'Menu'|i18n( 'design/exp_doc' )}</button>
{include uri='design:exp_doc/side_toggle.tpl' side_id='exp-doc-side' expanded=$doc_side_open}{/if}

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
{/if}

{include uri='design:exp_doc/cookie_consent.tpl'}
{include uri='design:parts/expwt_page_toolbar.tpl'}
{if $doc_help}<script type="module" src={'javascript/exp-doc-resizer.js'|ezdesign}></script>{/if}
<script type="module" src={'javascript/exp-doc-rating.js'|ezdesign}></script>
{include uri='design:exp_doc/analytics.tpl'}
</body>
</html>
{undef $doc_root_id $doc_path $doc_seen $doc_node_id $doc_is_front $doc_is_product $doc_help $doc_side_open $doc_confluence}
