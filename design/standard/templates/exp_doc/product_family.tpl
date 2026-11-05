{* exp_doc/product_family: the product's place in the family on its landing page (fetch exp_doc/product_landing,
   .family: every product of exp_doc.ini [ModernSettings] ProductList[], in that order): one .a4-tag link per product,
   the current one marked (aria-current, .is-accent) and not linked, then the help center's guide that compares them
   ([ProductLandingSettings] CompareURL). Styles: components.css and the design's .exp-doc-product-family.

   Variables: family, heading_id (the id of the heading this list belongs to). *}
<ul class="a4-plain exp-doc-product-family" aria-labelledby="{$heading_id|wash}">
{foreach $family as $doc_product}
    <li>{if $doc_product.current}<span class="a4-tag is-accent" aria-current="page">{$doc_product.name|wash}</span>{else}<a class="a4-tag" href={$doc_product.path|ezurl}>{$doc_product.name|wash}</a>{/if}</li>
{/foreach}
</ul>
{if ezini( 'ProductLandingSettings', 'CompareURL', 'exp_doc.ini' )|ne( '' )}
<p class="exp-doc-landing-more"><a href={ezini( 'ProductLandingSettings', 'CompareURL', 'exp_doc.ini' )|ezurl}>{'Which one should I choose?'|i18n( 'design/exp_doc' )}</a></p>
{/if}
