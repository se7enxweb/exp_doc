{* The full view of a documentation page in the Classic design, as the static site rendered it: the heading, the
   body (the editable XML; the original HTML is shown when the page has no XML body), the page break, the "Written
   by / Last updated by" box when the page has an author, then the comments (parts/doc_comments.tpl), which sit
   outside the page's own three boxes. The pagelayout opens and closes .area-docmain-normal. *}
{def $doc_map = $node.data_map}
<div class="template-design">
<div class="template-module content-view-full">
<div class="template-object">

<div class="attribute-heading">
<h1>{$node.name|wash}</h1>
</div>

{if and( is_set( $doc_map.body ), $doc_map.body.has_content )}
{attribute_view_gui attribute=$doc_map.body}
{elseif is_set( $doc_map.original_html )}
{$doc_map.original_html.content}
{/if}

<div class="break"></div>{include uri='design:parts/doc_pageinfo.tpl' node=$node}
<hr class="hide" />

</div>
</div>
</div>
{include uri='design:parts/doc_comments.tpl' node=$node}
{undef $doc_map}
