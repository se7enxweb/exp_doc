{* The Classic design (doc2025): the page frame of the static Exponential documentation site, element for element.
   The differences from the static pages are the modern exceptions the owner allowed:
   - HTTPS addresses only, and no inline scripts or styles (the static @import block and the onload handler are
     replaced by the packed stylesheets; the old menu and search scripts are not needed, see javascript/README);
   - the header switches (parts/switches.tpl): Classic / Modern and the content languages;
   - the viewport meta and the cookie banner;
   - no third-party trackers (the static gtag snippet is left out).
   Everything inside #page matches the static markup after whitespace normalization (the diff suite checks it). *}
{def $doc_path = $module_result.path
     $doc_node_id = $module_result.node_id
     $doc_is_front = false()}
{if and( is_set( $module_result.node_id ), eq( $module_result.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ) )}
    {set $doc_is_front = true()}
{/if}
<!DOCTYPE html>
<html lang="{$site.http_equiv.Content-language|wash}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
{ezcss_load( array( 'core.css', 'classes.css', 'doc.css', 'ezdoc2024.css', 'doc2025.css' ) )}
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
<div id="main" class="float-break">

{include uri='design:parts/doc_menu.tpl' path=$doc_path node_id=$doc_node_id}
<div class="area-docmain-normal">
{$module_result.content}
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
</body>
</html>
{undef $doc_path $doc_node_id $doc_is_front}
