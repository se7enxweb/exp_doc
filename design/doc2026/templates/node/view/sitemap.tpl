{* The site map (content/view/sitemap/<node>, the footer's "Sitemap" with the site's root) in the Modern design: the
   node's children as the menus list them (fetch exp_doc/menu_children: without the Contributors, the media folder,
   the historical copies and the other classes and nodes of exp_doc.ini MenuHideClasses[] and MenuHideNodeRemoteIDs[]),
   each as a card with its own children below it, at most [ModernSettings] SitemapChildren of them and a link to the
   rest. *}
{def $doc_top = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $node.node_id, 'limit', ezini( 'ModernSettings', 'SitemapTop', 'exp_doc.ini' ) ) )
     $doc_more = ezini( 'ModernSettings', 'SitemapChildren', 'exp_doc.ini' )}
<article class="exp-doc-article exp-doc-sitemap">
    <h1 class="exp-doc-title">{'Sitemap'|i18n( 'design/exp_doc' )}</h1>
    <ul class="a4-plain exp-doc-sitemap-list">
    {foreach $doc_top as $doc_item}
        {def $doc_sub = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $doc_item.node_id, 'limit', $doc_more ) )}
        <li class="a4-card exp-doc-sitemap-item">
            <h2 class="exp-doc-sitemap-title"><a href={$doc_item.url_alias|ezurl}>{$doc_item.name|wash}</a></h2>
            {if $doc_sub|count}
            <ul class="a4-plain exp-doc-sitemap-sub">
            {foreach $doc_sub as $doc_child}<li><a href={$doc_child.url_alias|ezurl}>{$doc_child.name|wash}</a></li>{/foreach}
            {if eq( $doc_sub|count, $doc_more )}<li class="exp-doc-sitemap-more"><a href={$doc_item.url_alias|ezurl}>{'All pages of %name'|i18n( 'design/exp_doc', '', hash( '%name', $doc_item.name|wash ) )}</a></li>{/if}
            </ul>
            {/if}
        </li>
        {undef $doc_sub}
    {/foreach}
    </ul>
</article>
{undef $doc_top $doc_more}
