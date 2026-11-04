{* The kernel's site map (design/standard/templates/node/view/sitemap.tpl), unchanged but for what the documentation
   leaves out of its menus: both levels come from fetch exp_doc/menu_children, which leaves out the classes of
   exp_doc.ini [ClassicSettings] MenuHideClasses[] (historical copies, comments ...) and the nodes of
   MenuHideNodeRemoteIDs[] (the Contributors, the media folder) before the rows are laid out and the pages counted,
   so every row of two is full. Styled by the design's stylesheet only. *}
{let page_limit=10
     col_count=2
     children=fetch('exp_doc','menu_children',hash(parent_node_id,$node.node_id,limit,$page_limit,offset,first_set( $view_parameters.offset, 0 )))}

<div class="maincontentheader">
<h1>{"Site map"|i18n("design/standard/node/view")} {$node.name|wash}</h1>
</div>

<table width="100%" cellspacing="0" cellpadding="4">
<tr>
{section name=Child loop=$children}
    <td>
    <h2><a href={$Child:item.url_alias|ezurl}>{$Child:item.name}</a></h2>

    {let sub_children=fetch('exp_doc','menu_children',hash(parent_node_id,$Child:item.node_id,limit,$page_limit))}

    <ul>
    {section name=SubChild loop=$:sub_children}
    <li><a href={$:item.url_alias|ezurl}>{$:item.name}</a></li>
    {/section}
    </ul>

    {/let}

    </td>
    {delimiter modulo=$col_count}
</tr>
<tr>
    {/delimiter}
{/section}
</tr>
</table>
{/let}
