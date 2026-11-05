{* The full view of a documentation page in the Modern design: the title, the facts the page carries (author,
   dates, labels), the body (the editable XML; the original HTML when there is no XML body), its child pages as
   cards, the feedback form, and the edit link for signed-in editors. The class templates (full/<class>.tpl)
   include this one and give $before_body / $after_body for their own parts (the tutorial summary, the extension
   facts box), $body_html for a body they render themselves (the help topics, full/exp_doc_help_topic.tpl) and
   children=false() to leave out the child cards. The front page (content.ini [NodeSettings] RootNode) draws the landing instead (parts/doc_landing.tpl),
   a product's container its landing page (parts/doc_product_landing.tpl, fetch exp_doc/product_landing), and the
   Confluence container its spaces (parts/doc_platform_landing.tpl). A page of exp_doc.ini [PageDisplaySettings] draws
   its list after its own text: every product (exp_doc/landing_products.tpl) or every choice (exp_doc/landing_choose.tpl). *}
{def $doc_product_landing = fetch( 'exp_doc', 'product_landing', hash( 'node_id', $node.node_id ) )
     $doc_page_displays = ezini( 'PageDisplaySettings', 'Display', 'exp_doc.ini' )
     $doc_page_display = ''}
{if is_set( $doc_page_displays[$node.object.remote_id] )}{set $doc_page_display = $doc_page_displays[$node.object.remote_id]}{/if}
{if eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) )}
{include uri='design:parts/doc_landing.tpl' node=$node}
{elseif $doc_product_landing}
{include uri='design:parts/doc_product_landing.tpl' node=$node landing=$doc_product_landing}
{elseif eq( $node.object.remote_id, ezini( 'PlatformSettings', 'RemoteID', 'exp_doc.ini' ) )}
{include uri='design:parts/doc_platform_landing.tpl' node=$node}
{else}
{def $doc_map = $node.data_map}
<article class="exp-doc-article" data-exp-doc-article>
    <header class="exp-doc-article-head">
        <h1 class="exp-doc-title">{$node.name|wash}</h1>
        {include uri='design:parts/doc_byline.tpl' node=$node}
        {include uri='design:exp_doc/rating_form.tpl' node=$node}
    </header>
{if is_set( $before_body )}{$before_body}{/if}
    <div class="exp-doc-body" data-exp-doc-body>
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
    </div>
{if eq( $doc_page_display, 'products' )}{include uri='design:exp_doc/landing_products.tpl' heading=false()}{include uri='design:exp_doc/landing_partners.tpl' badge_class='exp-doc-version-badge is-supported'}
{elseif eq( $doc_page_display, 'choose' )}{include uri='design:exp_doc/landing_choose.tpl' heading=false()}{include uri='design:exp_doc/landing_partners.tpl' badge_class='exp-doc-version-badge is-supported' needs=true()}{/if}
{if is_set( $after_body )}{$after_body}{/if}
{* the Contributors folder lists every contributor below its own text *}
{if eq( $node.object.remote_id, ezini( 'RecentSettings', 'ContributorFolderRemoteID', 'exp_doc.ini' ) )}{include uri='design:parts/doc_contributor_list.tpl'}{/if}
    {if or( is_set( $children )|not, $children )}{include uri='design:parts/doc_children.tpl' node=$node}{/if}
    {include uri='design:parts/doc_contributors.tpl' node=$node}
    {include uri='design:parts/doc_historical_comments.tpl' node=$node}
    {include uri='design:parts/doc_page_comments.tpl' node=$node}
    {include uri='design:parts/doc_feedback.tpl' node=$node}
    {include uri='design:parts/doc_edit_link.tpl' node=$node}
</article>
{undef $doc_map}
{/if}
{undef $doc_product_landing $doc_page_displays $doc_page_display}
