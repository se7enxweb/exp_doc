{* The full view of a documentation page in the Classic design, as the static site rendered it: the heading, the
   body (the editable XML; the original HTML is shown when the page has no XML body), the page break, the "Written
   by / Last updated by" box when the page has an author, then the comments (parts/doc_comments.tpl), which sit
   outside the page's own three boxes. The pagelayout opens and closes .area-docmain-normal. *}
{def $doc_map = $node.data_map
     $doc_root_source = false()}
{* the root (a folder) shows the static start page from its description; while that is empty, the body of the page
   imported from exp_doc.ini [ClassicSettings] RootSource *}
{if and( eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ),
         or( is_set( $doc_map.description )|not, $doc_map.description.has_content|not ) )}
    {set $doc_root_source = fetch( 'exp_doc', 'node_by_source', hash( 'path', ezini( 'ClassicSettings', 'RootSource', 'exp_doc.ini' ) ) )}
    {if $doc_root_source}{set $doc_map = $doc_root_source.data_map}{/if}
{/if}
<div class="template-design">
<div class="template-module content-view-full">
<div class="template-object">

<div class="attribute-heading">
<h1>{cond( eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ), ezini( 'ClassicSettings', 'FrontHeading', 'exp_doc.ini' ), $node.name )|wash}</h1>
</div>

{if and( is_set( $doc_map.body ), $doc_map.body.has_content )}
{attribute_view_gui attribute=$doc_map.body}
{elseif and( is_set( $doc_map.answer ), $doc_map.answer.has_content )}
{attribute_view_gui attribute=$doc_map.answer}
{elseif and( is_set( $doc_map.description ), $doc_map.description.has_content )}
{attribute_view_gui attribute=$doc_map.description}
{elseif is_set( $doc_map.original_html )}
{$doc_map.original_html.content}
{/if}
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
{* the front page ends with the help center's bottom blocks (exp_doc/landing_org.tpl), below everything above *}
{if eq( $node.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) )}{include uri='design:exp_doc/landing_org.tpl' frame_class='a4-page'}{/if}
{undef $doc_map $doc_root_source}
