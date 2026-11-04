{* The site map (content/view/sitemap/<node>) in the Classic design: a page the static site did not have (a listed
   exception), in the static pages' frame and classes: the node's children as the menus list them (fetch
   exp_doc/menu_children: without the Contributors, the media folder and the historical copies), each with its own
   children, at most [ModernSettings] SitemapChildren of them and a link to the rest. *}
{def $doc_top = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $node.node_id ) )
     $doc_more = ezini( 'ModernSettings', 'SitemapChildren', 'exp_doc.ini' )}
<div class="template-design">
<div class="template-module content-view-full exp-doc-sitemap-classic">
<div class="template-object">

<div class="attribute-heading">
<h1>{'Sitemap'|i18n( 'design/exp_doc' )}</h1>
</div>

{foreach $doc_top as $doc_item}
{def $doc_sub = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $doc_item.node_id, 'limit', $doc_more ) )}
<h2><a href={$doc_item.url_alias|ezurl}>{$doc_item.name|wash}</a></h2>
{if $doc_sub|count}
<ul>
{foreach $doc_sub as $doc_child}<li><div><a href={$doc_child.url_alias|ezurl}>{$doc_child.name|wash}</a></div></li>{/foreach}
{if eq( $doc_sub|count, $doc_more )}<li><div><a href={$doc_item.url_alias|ezurl}>{'All pages of %name'|i18n( 'design/exp_doc', '', hash( '%name', $doc_item.name|wash ) )}</a></div></li>{/if}
</ul>
{/if}
{undef $doc_sub}
{/foreach}

<div class="break"></div>
<hr class="hide" />

</div>
</div>
</div>
{undef $doc_top $doc_more}
