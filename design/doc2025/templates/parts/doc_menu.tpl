{* The left column of a Classic page, as on the static site. It is one of four menus, chosen by the nearest node
   on the page's path (the page itself included) whose class is named in exp_doc.ini [ClassicSettings]:
   - TocRootClasses[] (a manual version, an extension), or a section whose static source is in TocRootSources[]:
     "Table of contents", the root's chapters, the open chapter two levels deep (parts/doc_menu_toc.tpl);
   - StepsRootClasses[] (a tutorial): "Table of contents", the tutorial's steps (parts/doc_menu_steps.tpl);
   - ListRootClasses[] (the FAQ and similar sections): the section's name and its pages as a flat list
     (parts/doc_menu_list.tpl);
   - none of them: the quick links (parts/doc_menu_quicklinks.tpl).
   resizable (the help center's pages): the column takes the id exp-doc-side and the resize handle
   (javascript/exp-doc-resizer.js). *}
{def $doc_menu_root = false()
     $doc_menu_kind = 'quicklinks'
     $doc_toc_classes = ezini( 'ClassicSettings', 'TocRootClasses', 'exp_doc.ini' )
     $doc_toc_sources = ezini( 'ClassicSettings', 'TocRootSources', 'exp_doc.ini' )
     $doc_steps_classes = ezini( 'ClassicSettings', 'StepsRootClasses', 'exp_doc.ini' )
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
        {if or( $doc_toc_classes|contains( $doc_candidate.class_identifier ),
                and( is_set( $doc_candidate.data_map.source_path ), $doc_toc_sources|contains( $doc_candidate.data_map.source_path.content|trim ) ) )}
            {set $doc_menu_root = $doc_candidate $doc_menu_kind = 'toc'}{break}
        {elseif $doc_steps_classes|contains( $doc_candidate.class_identifier )}
            {set $doc_menu_root = $doc_candidate $doc_menu_kind = 'steps'}{break}
        {elseif $doc_list_classes|contains( $doc_candidate.class_identifier )}
            {set $doc_menu_root = $doc_candidate $doc_menu_kind = 'list'}{break}
        {/if}
    {/if}
{/foreach}
<div class="template-design area-docmenu-normal"{if and( is_set( $resizable ), $resizable )} id="exp-doc-side" data-exp-side{/if}>
<div class="template-module">
<div class="template-object">
<div id="contentmenu">
{if and( is_set( $module_result.left_menu ), $module_result.left_menu )}
{include uri=$module_result.left_menu uri_string=$site.uri.original_uri}
{elseif eq( $doc_menu_kind, 'toc' )}
{include uri='design:parts/doc_menu_toc.tpl' root=$doc_menu_root path_ids=$doc_ids current_id=$node_id}
{elseif eq( $doc_menu_kind, 'steps' )}
{include uri='design:parts/doc_menu_steps.tpl' root=$doc_menu_root current_id=$node_id}
{elseif eq( $doc_menu_kind, 'list' )}
{include uri='design:parts/doc_menu_list.tpl' root=$doc_menu_root current_id=$node_id}
{else}
{include uri='design:parts/doc_menu_quicklinks.tpl'}
{/if}
</div>
</div>
</div>
{if and( is_set( $resizable ), $resizable )}<div class="exp-doc-resizer" data-exp-resizer role="separator" aria-orientation="vertical" aria-controls="exp-doc-side" tabindex="0" aria-label="{'Resize the menu'|i18n( 'design/exp_doc' )}" title="{'Drag, or use the arrow keys, to resize the menu'|i18n( 'design/exp_doc' )}"></div>{/if}
</div>
{undef $doc_menu_root $doc_menu_kind $doc_toc_classes $doc_toc_sources $doc_steps_classes $doc_list_classes $doc_candidate $doc_ids}
