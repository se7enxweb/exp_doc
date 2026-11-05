{* The full view of a documentation page in the Classic design, as the static site rendered it: the heading, the
   body (the editable XML; the original HTML is shown when the page has no XML body), the page break, the "Written
   by / Last updated by" box when the page has an author, then the comments (parts/doc_comments.tpl), which sit
   outside the page's own three boxes. The pagelayout opens and closes .area-docmain-normal. A class template gives
   $body_html for a body it renders itself (the help topics, full/exp_doc_help_topic.tpl). *}
{def $doc_map = $node.data_map
     $doc_root_source = false()
     $doc_is_root = eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) )
     $doc_start = false()
     $doc_page_displays = ezini( 'PageDisplaySettings', 'Display', 'exp_doc.ini' )
     $doc_page_display = ''}
{* a page of exp_doc.ini [PageDisplaySettings]: its list after its own text (every product, exp_doc/landing_products.tpl,
   in the product box's cards; every choice, exp_doc/landing_choose.tpl), a listed exception like the front page's
   frames: the help center's components, light (the pagelayout loads them on these pages) *}
{if is_set( $doc_page_displays[$node.object.remote_id] )}{set $doc_page_display = $doc_page_displays[$node.object.remote_id]}{/if}
{* "Start where you are" below the front page's current lists, while the help is on (as the bottom blocks) *}
{if $doc_is_root}{if fetch( 'exp_doc', 'help_report' )}{set $doc_start = true()}{/if}{/if}
{* the root (a folder) shows the static start page from its description; while that is empty, the body of the page
   imported from exp_doc.ini [ClassicSettings] RootSource *}
{if and( eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ),
         or( is_set( $doc_map.description )|not, $doc_map.description.has_content|not ) )}
    {set $doc_root_source = fetch( 'exp_doc', 'node_by_source', hash( 'path', ezini( 'ClassicSettings', 'RootSource', 'exp_doc.ini' ) ) )}
    {if $doc_root_source}{set $doc_map = $doc_root_source.data_map}{/if}
{/if}
{* a page of the former documentation center's Confluence spaces (fetch exp_doc/confluence_context): its page panel in
   the static site's Atlassian markup (parts/confluence_page.tpl; the pagelayout draws the frame around it), with the
   same body *}
{def $doc_cf = cond( $doc_is_root, false(), fetch( 'exp_doc', 'confluence_context', hash( 'node_id', $node.node_id ) ) )}
{if $doc_cf}
{set-block variable=$doc_body}
{if is_set( $body_html )}
{$body_html}
{elseif and( is_set( $doc_map.body ), $doc_map.body.has_content )}
{attribute_view_gui attribute=$doc_map.body}
{elseif and( is_set( $doc_map.answer ), $doc_map.answer.has_content )}
{attribute_view_gui attribute=$doc_map.answer}
{elseif and( is_set( $doc_map.description ), $doc_map.description.has_content )}
{attribute_view_gui attribute=$doc_map.description}
{elseif is_set( $doc_map.original_html )}
{$doc_map.original_html.content}
{/if}
{/set-block}
{include uri='design:parts/confluence_page.tpl' node=$node context=$doc_cf body_html=$doc_body}
{else}
<div class="template-design">
<div class="template-module content-view-full">
<div class="template-object">

<div class="attribute-heading">
<h1>{cond( eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ), ezini( 'ClassicSettings', 'FrontHeading', 'exp_doc.ini' ), $node.name )|wash}</h1>
</div>

{* a product's container (exp_doc.ini [ModernSettings] ProductList[], fetch exp_doc/product_landing): the product's
   box after the heading, before the page's own text (a listed exception, .exp-doc-product): its short text and
   Supported badge, its links, its sections and related sections as the help center's cards, and its place in the
   family; the help center's components and tokens, light (the pagelayout loads them on these pages) *}
{if $doc_is_root|not}
{def $doc_landing = fetch( 'exp_doc', 'product_landing', hash( 'node_id', $node.node_id ) )}
{if $doc_landing}
<div class="a4-page a4-help-frame exp-doc-product">
    <section class="a4-card exp-doc-product-intro" aria-label="{$doc_landing.product.name|wash}">
        {if $doc_landing.product.text}<p class="exp-doc-product-text">{$doc_landing.product.text|wash}{if $doc_landing.product.supported} <span class="a4-badge is-ok">{'Supported'|i18n( 'design/exp_doc' )}</span>{/if}</p>{/if}
        {if $doc_landing.links|count}<p class="exp-doc-product-links">{include uri='design:exp_doc/product_links.tpl' links=$doc_landing.links}</p>{/if}
    </section>
    {if $doc_landing.sections|count}
    <section aria-labelledby="exp-doc-product-sections-title">
        <h2 id="exp-doc-product-sections-title" class="a4-h2">{'Sections'|i18n( 'design/exp_doc' )}</h2>
        {include uri='design:exp_doc/product_cards.tpl' sections=$doc_landing.sections list_class='a4-grid is-wide' badge_class='a4-badge is-ok'}
        {if $doc_landing.section_count|gt( $doc_landing.sections|count )}<p class="exp-doc-landing-more"><a href={concat( 'content/view/sitemap/', $node.node_id )|ezurl}>{'Browse all %count sections'|i18n( 'design/exp_doc', '', hash( '%count', $doc_landing.section_count ) )}</a></p>{/if}
    </section>
    {/if}
    {if $doc_landing.related|count}
    <section aria-labelledby="exp-doc-product-related-title">
        <h2 id="exp-doc-product-related-title" class="a4-h2">{'From the former documentation center'|i18n( 'design/exp_doc' )}</h2>
        {include uri='design:exp_doc/product_cards.tpl' sections=$doc_landing.related list_class='a4-grid is-wide' badge_class='a4-badge is-ok'}
    </section>
    {/if}
    <section class="a4-card exp-doc-product-family-box" aria-labelledby="exp-doc-product-family-title">
        <h2 id="exp-doc-product-family-title" class="a4-h2">{'The Exponential family'|i18n( 'design/exp_doc' )}</h2>
        {include uri='design:exp_doc/product_family.tpl' family=$doc_landing.family heading_id='exp-doc-product-family-title'}
    </section>
</div>
{/if}
{undef $doc_landing}
{/if}

{* on the front page "Who makes Exponential" (the help dashboard's exphelp/parts/dashboard_about.tpl, a listed
   exception) comes first, before the static page's content, as Modern draws it above the manuals; the bottom blocks
   then leave it out *}
{if $doc_start}
<div class="a4-page a4-help-frame exp-doc-landing-about">
    {include uri='design:exphelp/parts/dashboard_about.tpl' landing_on=ezini( 'LandingSettings', 'Enabled', 'exphelp.ini' )|eq( 'enabled' )}
</div>
{/if}

{* the body; on the front page "Start where you are" (exp_doc/landing_start.tpl, a listed exception) follows the
   static page's current lists, before the body's first second-level heading (the earlier front page): Classic has
   no products list to draw it below, as Modern does; a body without such a heading gets the card after it. Right
   before it "Choosing a product" (exp_doc/landing_choose.tpl), where Modern draws it right before the products *}
{set-block variable=$doc_body}
{if is_set( $body_html )}
{$body_html}
{elseif and( is_set( $doc_map.body ), $doc_map.body.has_content )}
{attribute_view_gui attribute=$doc_map.body}
{elseif and( is_set( $doc_map.answer ), $doc_map.answer.has_content )}
{attribute_view_gui attribute=$doc_map.answer}
{elseif and( is_set( $doc_map.description ), $doc_map.description.has_content )}
{attribute_view_gui attribute=$doc_map.description}
{elseif is_set( $doc_map.original_html )}
{$doc_map.original_html.content}
{/if}
{/set-block}
{if $doc_start}
{def $doc_body_parts = $doc_body|explode( '<h2' )}
{$doc_body_parts.0}{include uri='design:exp_doc/landing_choose.tpl' framed=true() frame_class='a4-page'}{include uri='design:exp_doc/landing_start.tpl' framed=true() frame_class='a4-page'}{if $doc_body_parts|count|gt( 1 )}<h2{$doc_body_parts|extract( 1 )|implode( '<h2' )}{/if}
{undef $doc_body_parts}
{else}
{$doc_body}
{/if}
{if eq( $doc_page_display, 'products' )}<div class="a4-page a4-help-frame exp-doc-product exp-doc-page-products">{include uri='design:exp_doc/landing_products.tpl' heading=false() list_class='a4-grid is-wide' badge_class='a4-badge is-ok'}</div>
{elseif eq( $doc_page_display, 'choose' )}{include uri='design:exp_doc/landing_choose.tpl' framed=true() frame_class='a4-page' heading=false()}{/if}
{* the Contributors folder lists every contributor below its own text (a listed exception) *}
{if eq( $node.object.remote_id, ezini( 'RecentSettings', 'ContributorFolderRemoteID', 'exp_doc.ini' ) )}{include uri='design:parts/doc_contributor_list.tpl'}{/if}

{if and( is_set( $doc_map.source_path ), ezini( 'ClassicSettings', 'ConfluencePrefixes', 'exp_doc.ini' )|contains( $doc_map.source_path.content|explode( '/' ).0 ) )}{include uri='design:parts/doc_confluence_meta.tpl' node=$node}<div class="break"></div>{else}<div class="break"></div>{include uri='design:parts/doc_pageinfo.tpl' node=$node}{/if}{include uri='design:parts/doc_contributors.tpl' node=$node}
{* the page's rating (a listed exception of the check: form.exp-doc-rating) *}
{include uri='design:exp_doc/rating_form.tpl' node=$node}
<hr class="hide" />

</div>
</div>
</div>
{include uri='design:parts/doc_comments.tpl' node=$node}
{* the front page ends with the help center's bottom blocks (exp_doc/landing_org.tpl), below everything above, without
   the start card and "Who makes Exponential" drawn higher up *}
{if eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) )}{include uri='design:exp_doc/landing_org.tpl' frame_class='a4-page' start=$doc_start|not about=$doc_start|not}{/if}
{/if}
{undef $doc_map $doc_root_source $doc_is_root $doc_start $doc_body $doc_cf $doc_page_displays $doc_page_display}
