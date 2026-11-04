{* The left column of a Classic page, as on the static site. It is one of three menus, chosen by the nearest node
   on the page's path (the page itself included) whose class is named in exp_doc.ini [ClassicSettings]:
   - TocRootClasses[] (a manual version): "Table of contents", the version's chapters, the open chapter two levels
     deep (parts/doc_menu_toc.tpl);
   - ListRootClasses[] (the FAQ and similar sections): the section's name and its pages as a flat list
     (parts/doc_menu_list.tpl);
   - none of them: the quick links (parts/doc_menu_quicklinks.tpl). *}
{def $doc_menu_root = false()
     $doc_menu_kind = 'quicklinks'
     $doc_toc_classes = ezini( 'ClassicSettings', 'TocRootClasses', 'exp_doc.ini' )
     $doc_list_classes = ezini( 'ClassicSettings', 'ListRootClasses', 'exp_doc.ini' )
     $doc_candidate = false()
     $doc_ids = array()}
{foreach $path as $item}
    {if is_set( $item.node_id )}{set $doc_ids = $doc_ids|append( $item.node_id )}{/if}
{/foreach}
{if $node_id}{set $doc_ids = $doc_ids|append( $node_id )}{/if}
{foreach $doc_ids|reverse as $candidate_id}
    {set $doc_candidate = fetch( 'content', 'node', hash( 'node_id', $candidate_id ) )}
    {if $doc_candidate}
        {if $doc_toc_classes|contains( $doc_candidate.class_identifier )}
            {set $doc_menu_root = $doc_candidate $doc_menu_kind = 'toc'}{break}
        {elseif $doc_list_classes|contains( $doc_candidate.class_identifier )}
            {set $doc_menu_root = $doc_candidate $doc_menu_kind = 'list'}{break}
        {/if}
    {/if}
{/foreach}
<div class="template-design area-docmenu-normal">
<div class="template-module">
<div class="template-object">
<div id="contentmenu">
{if and( is_set( $module_result.left_menu ), $module_result.left_menu )}
{include uri=$module_result.left_menu uri_string=$site.uri.original_uri}
{elseif eq( $doc_menu_kind, 'toc' )}
{include uri='design:parts/doc_menu_toc.tpl' root=$doc_menu_root path_ids=$doc_ids current_id=$node_id}
{elseif eq( $doc_menu_kind, 'list' )}
{include uri='design:parts/doc_menu_list.tpl' root=$doc_menu_root current_id=$node_id}
{else}
{include uri='design:parts/doc_menu_quicklinks.tpl'}
{/if}
</div>
</div>
</div>
</div>
{undef $doc_menu_root $doc_menu_kind $doc_toc_classes $doc_list_classes $doc_candidate $doc_ids}
