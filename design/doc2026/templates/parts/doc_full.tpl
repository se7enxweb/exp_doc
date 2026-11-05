{* The full view of a documentation page in the Modern design: the title, the facts the page carries (author,
   dates, labels), the body (the editable XML; the original HTML when there is no XML body), its child pages as
   cards, the feedback form, and the edit link for signed-in editors. The class templates (full/<class>.tpl)
   include this one and give $before_body / $after_body for their own parts (the tutorial summary, the extension
   facts box). The front page (content.ini [NodeSettings] RootNode) draws the landing instead (parts/doc_landing.tpl),
   a product's container its landing page (parts/doc_product_landing.tpl, fetch exp_doc/product_landing), and the
   Confluence container its spaces (parts/doc_platform_landing.tpl). *}
{def $doc_product_landing = fetch( 'exp_doc', 'product_landing', hash( 'node_id', $node.node_id ) )}
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
{if and( is_set( $doc_map.body ), $doc_map.body.has_content )}
{attribute_view_gui attribute=$doc_map.body}
{elseif and( is_set( $doc_map.answer ), $doc_map.answer.has_content )}
{attribute_view_gui attribute=$doc_map.answer}
{elseif and( is_set( $doc_map.description ), $doc_map.description.has_content )}
{attribute_view_gui attribute=$doc_map.description}
{elseif is_set( $doc_map.original_html )}
{$doc_map.original_html.content}
{/if}
    </div>
{if is_set( $after_body )}{$after_body}{/if}
{* the Contributors folder lists every contributor below its own text *}
{if eq( $node.object.remote_id, ezini( 'RecentSettings', 'ContributorFolderRemoteID', 'exp_doc.ini' ) )}{include uri='design:parts/doc_contributor_list.tpl'}{/if}
    {include uri='design:parts/doc_children.tpl' node=$node}
    {include uri='design:parts/doc_contributors.tpl' node=$node}
    {include uri='design:parts/doc_historical_comments.tpl' node=$node}
    {include uri='design:parts/doc_page_comments.tpl' node=$node}
    {include uri='design:parts/doc_feedback.tpl' node=$node}
    {include uri='design:parts/doc_edit_link.tpl' node=$node}
</article>
{undef $doc_map}
{/if}
{undef $doc_product_landing}
