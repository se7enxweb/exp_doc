{* One level of the Modern page tree (parts/doc_tree.tpl). A page with children gets a button that opens its
   branch; the branch of the page shown is drawn open, the others are drawn when opened (their children come from
   the server as a link list, [ModernSettings] TreeDepth levels deep, so the tree also works without JavaScript). *}
{def $doc_items = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $parent.node_id ) )
     $doc_max = ezini( 'ModernSettings', 'TreeDepth', 'exp_doc.ini' )}
{if $doc_items|count}
<ul class="exp-doc-tree-list{if gt( $depth, 1 )} exp-doc-tree-sub{/if}">
{foreach $doc_items as $item}
    {def $doc_open = $path_ids|contains( $item.node_id )
         $doc_has = and( lt( $depth, $doc_max ), $item.children_count|gt( 0 ) )}
    <li class="exp-doc-tree-item{if $doc_open} is-open{/if}">
        <div class="exp-doc-tree-row">
        {if $doc_has}
            <button type="button" class="exp-doc-tree-toggle" aria-expanded="{cond( $doc_open, 'true', 'false' )}"
                    aria-controls="exp-doc-tree-{$item.node_id}" data-exp-doc-tree-toggle hidden>
                <span class="a4-sr-only">{'Open %name'|i18n( 'design/exp_doc', '', hash( '%name', $item.name|wash ) )}</span>
            </button>
        {/if}
            <a href={$item.url_alias|ezurl}{if eq( $item.node_id, $current_id )} aria-current="page"{/if}>{$item.name|wash}</a>
        </div>
    {if $doc_has}
        <div id="exp-doc-tree-{$item.node_id}" class="exp-doc-tree-branch"{if not( $doc_open )} data-exp-doc-tree-closed{/if}>
        {include uri='design:parts/doc_tree_level.tpl' parent=$item path_ids=$path_ids current_id=$current_id depth=inc( $depth )}
        </div>
    {/if}
    </li>
    {undef $doc_open $doc_has}
{/foreach}
</ul>
{/if}
{undef $doc_items $doc_max}
