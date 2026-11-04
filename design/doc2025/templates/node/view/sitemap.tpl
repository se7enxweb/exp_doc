{* The kernel's site map (design/standard/templates/node/view/sitemap.tpl), unchanged but for what the documentation
   leaves out of its menus: the classes of exp_doc.ini [ClassicSettings] MenuHideClasses[] (historical copies,
   comments ...) are not fetched, and the nodes of MenuHideNodeRemoteIDs[] (the Contributors and the media folder)
   are skipped. Styled by the design's stylesheet only. *}
{let page_limit=10
     col_count=2
     hide_classes=ezini( 'ClassicSettings', 'MenuHideClasses', 'exp_doc.ini' )
     children=fetch('content','list',hash(parent_node_id,$node.node_id,limit,$page_limit,offset,$view_parameters.offset,
                                          class_filter_type,'exclude',class_filter_array,$hide_classes))}

<div class="maincontentheader">
<h1>{"Site map"|i18n("design/standard/node/view")} {$node.name|wash}</h1>
</div>

<table width="100%" cellspacing="0" cellpadding="4">
<tr>
{section name=Child loop=$children}
    {if ezini( 'ClassicSettings', 'MenuHideNodeRemoteIDs', 'exp_doc.ini' )|contains( $Child:item.object.remote_id )|not}{if ezini( 'ClassicSettings', 'MenuHideNodeRemoteIDs', 'exp_doc.ini' )|contains( $Child:item.remote_id )|not}
    <td>
    <h2><a href={$Child:item.url_alias|ezurl}>{$Child:item.name}</a></h2>

    {let sub_children=fetch('content','list',hash(parent_node_id,$Child:item.node_id,limit,$page_limit,
                                                  class_filter_type,'exclude',class_filter_array,ezini( 'ClassicSettings', 'MenuHideClasses', 'exp_doc.ini' )))}

    <ul>
    {section name=SubChild loop=$:sub_children}
    {if ezini( 'ClassicSettings', 'MenuHideNodeRemoteIDs', 'exp_doc.ini' )|contains( $:item.object.remote_id )|not}{if ezini( 'ClassicSettings', 'MenuHideNodeRemoteIDs', 'exp_doc.ini' )|contains( $:item.remote_id )|not}
    <li><a href={$:item.url_alias|ezurl}>{$:item.name}</a></li>
    {/if}{/if}
    {/section}
    </ul>

    {/let}

    </td>
    {/if}{/if}
    {delimiter modulo=$col_count}
</tr>
<tr>
    {/delimiter}
{/section}
</tr>
</table>
{/let}
