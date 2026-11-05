{* One level of the Modern page tree (parts/doc_tree.tpl). A page without children gets a bullet in the button's
   place; so does a page whose only children are ones the menus leave out, such as comments (the script swaps its
   button for the bullet when the branch comes out empty). A page with children gets a button that opens its
   branch; the branch of the page shown is drawn open, the others are drawn when opened (their children come from
   the server as a link list, [ModernSettings] TreeDepth levels deep, or max_depth; the branch of the page shown always,
   so the tree also works without JavaScript). *}
{def $doc_items = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $parent.node_id, 'limit', first_set( $limit, false() ) ) )
     $doc_max = first_set( $max_depth, ezini( 'ModernSettings', 'TreeDepth', 'exp_doc.ini' ) )}
{if $doc_items|count}
<ul class="exp-doc-tree-list{if gt( $depth, 1 )} exp-doc-tree-sub{/if}">
{foreach $doc_items as $item}
    {def $doc_open = $path_ids|contains( $item.node_id )
         $doc_has = and( or( $doc_open, lt( $depth, $doc_max ) ), $item.children_count|gt( 0 ) )}
    <li class="exp-doc-tree-item{if $doc_open} is-open{/if}">
        <div class="exp-doc-tree-row">
        {if $doc_has}
            <button type="button" class="exp-doc-tree-toggle" aria-expanded="{cond( $doc_open, 'true', 'false' )}"
                    aria-controls="exp-doc-tree-{$item.node_id}" data-exp-doc-tree-toggle hidden>
                <span class="a4-sr-only">{'Open %name'|i18n( 'design/exp_doc', '', hash( '%name', $item.name|wash ) )}</span>
            </button>
        {else}
            <span class="exp-doc-tree-leaf" aria-hidden="true"></span>
        {/if}
            <a href={$item.url_alias|ezurl}{if eq( $item.node_id, $current_id )} aria-current="page"{/if}>{$item.name|wash}</a>
        </div>
    {if $doc_has}
        <div id="exp-doc-tree-{$item.node_id}" class="exp-doc-tree-branch"{if not( $doc_open )} data-exp-doc-tree-closed{/if}>
        {include uri='design:parts/doc_tree_level.tpl' parent=$item path_ids=$path_ids current_id=$current_id depth=inc( $depth ) max_depth=$doc_max}
        </div>
    {/if}
    </li>
    {undef $doc_open $doc_has}
{/foreach}
{if and( is_set( $limit ), $limit, eq( $doc_items|count, $limit ) )}
    <li class="exp-doc-tree-item exp-doc-tree-more"><div class="exp-doc-tree-row"><a href={$parent.url_alias|ezurl}>{'All pages'|i18n( 'design/exp_doc' )}</a></div></li>
{/if}
</ul>
{/if}
{undef $doc_items $doc_max}
