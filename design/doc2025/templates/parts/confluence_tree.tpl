{* One level of a Confluence space's page tree in the Classic design (parts/confluence_frame.tpl): each page in
   Confluence's page tree markup (the toggle, the title, the container of its children); a page with pages below it
   shows the closed or the open toggle, the page on show is marked (plugin_pagetree_current, aria-current), and the
   branch down to it is open. The toggle links the page, whose own tree is then open. Parameters: items (the levels of
   fetch exp_doc/confluence_context, tree). *}
{foreach $items as $cf_item}
<li>
    <div class="plugin_pagetree_childtoggle_container">{if $cf_item.has_children}<a class="plugin_pagetree_childtoggle aui-icon aui-icon-small {if or( $cf_item.open, $cf_item.current )}aui-iconfont-chevron-down{else}aui-iconfont-chevron-right{/if}" href={$cf_item.node.url_alias|ezurl} tabindex="-1" aria-hidden="true"></a>{else}<span class="no-children icon"></span>{/if}</div>
    <div class="plugin_pagetree_children_content"><span class="plugin_pagetree_children_span{if $cf_item.current} plugin_pagetree_current{/if}"><a href={$cf_item.node.url_alias|ezurl}{if $cf_item.current} aria-current="page"{/if}>{$cf_item.title|wash}</a></span></div>
{if $cf_item.children|count}
    <div class="plugin_pagetree_children_container">
        <ul class="plugin_pagetree_children_list">
{include uri='design:parts/confluence_tree.tpl' items=$cf_item.children}
        </ul>
    </div>
{/if}
</li>
{/foreach}
