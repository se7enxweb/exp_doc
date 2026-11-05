{* The landing page of a product's container in the Modern design (the node at a path of exp_doc.ini [ModernSettings]
   ProductList[]: /exponential, /platform, /platform/legacy, /platform/nexus, /platform/dxp, /basic), in the front
   page's components (parts/doc_landing.tpl):
   - the hero (.a4-help-hero): the product it belongs to, the product's name with its Supported badge, its short text
     (the description of the container's Metadata attribute) and its links ([ProductLanding_<path>] Links[]:
     install, upgrade, GitHub, Packagist, the website), exp_doc/product_links.tpl;
   - its sections as cards (the container's children without [ProductLandingSettings] HideSectionClasses[], at most
     MaxSections, then a link to all of them), exp_doc/product_cards.tpl: a manual with its versions, a product with
     its text and badge, any other section with its number of pages;
   - the sections elsewhere on the site that belong to it (Related[]: its spaces of the former documentation center);
   - the container's own text (its body; ShowBody=disabled where the body is the static page the container came
     from, which Classic shows);
   - the recently changed pages below it (or below its related sections) and its place in the family, in the front
     page's .a4-help-support boxes.
   Classic keeps the container's page and adds the product's box (design/doc2025 parts/doc_full.tpl).

   Variables: node, landing (fetch exp_doc/product_landing). *}
{def $doc_product = $landing.product}
<section class="a4-help-hero exp-doc-hero exp-doc-product-hero" aria-labelledby="exp-doc-product-title">
{if $landing.parent}
    <p class="a4-help-hero-pre"><a href={$landing.parent.path|ezurl}>{$landing.parent.name|wash}</a></p>
{/if}
    <h1 id="exp-doc-product-title" class="exp-doc-hero-title">{$doc_product.name|wash}{if $doc_product.supported} <span class="exp-doc-version-badge is-supported">{'Supported'|i18n( 'design/exp_doc' )}</span>{/if}</h1>
{if $doc_product.text}
    <p class="a4-help-hero-sub">{$doc_product.text|wash}</p>
{/if}
{if $landing.links|count}
    <p class="a4-help-hero-actions">{include uri='design:exp_doc/product_links.tpl' links=$landing.links}</p>
{/if}
</section>

{if $landing.sections|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-product-sections-title">
    <h2 id="exp-doc-product-sections-title" class="a4-h2">{'Sections'|i18n( 'design/exp_doc' )}</h2>
    {include uri='design:exp_doc/product_cards.tpl' sections=$landing.sections list_class='exp-doc-manuals' badge_class='exp-doc-version-badge is-supported' version_tags=true()}
    {if $landing.section_count|gt( $landing.sections|count )}
    <p class="exp-doc-landing-more"><a href={concat( 'content/view/sitemap/', $node.node_id )|ezurl}>{'Browse all %count sections'|i18n( 'design/exp_doc', '', hash( '%count', $landing.section_count ) )}</a></p>
    {/if}
</section>
{/if}

{if $landing.related|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-product-related-title">
    <h2 id="exp-doc-product-related-title" class="a4-h2">{'From the former documentation center'|i18n( 'design/exp_doc' )}</h2>
    {include uri='design:exp_doc/product_cards.tpl' sections=$landing.related list_class='exp-doc-manuals' badge_class='exp-doc-version-badge is-supported' version_tags=true()}
</section>
{/if}

{if $landing.show_body}
<section class="exp-doc-landing-section exp-doc-product-about" aria-labelledby="exp-doc-product-about-title">
    <h2 id="exp-doc-product-about-title" class="a4-h2">{'About %product'|i18n( 'design/exp_doc', '', hash( '%product', $doc_product.name ) )|wash}</h2>
    <div class="exp-doc-body">{attribute_view_gui attribute=$node.data_map.body}</div>
</section>
{/if}

<div class="exp-doc-landing-columns">
{if $landing.recent|count}
<section class="a4-help-support exp-doc-landing-section" aria-labelledby="exp-doc-product-recent-title">
    <h2 id="exp-doc-product-recent-title" class="a4-h2">{'Recently changed'|i18n( 'design/exp_doc' )}</h2>
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $landing.recent as $doc_item}
        <li><a href={$doc_item.url_alias|ezurl}>{$doc_item.name|wash}</a> <span class="a4-meta">{$doc_item.object.modified|l10n( 'shortdate' )}</span></li>
    {/foreach}
    </ol>
    {if $landing.recent_node_id}
    <p class="exp-doc-landing-more"><a href={concat( ezini( 'RecentSettings', 'Path', 'exp_doc.ini' ), '/(manual)/', $landing.recent_node_id )|ezurl}>{'See all changes'|i18n( 'design/exp_doc' )}</a></p>
    {/if}
</section>
{/if}
<section class="a4-help-support exp-doc-landing-section is-accent" aria-labelledby="exp-doc-product-family-title">
    <h2 id="exp-doc-product-family-title" class="a4-h2">{'The Exponential family'|i18n( 'design/exp_doc' )}</h2>
    {include uri='design:exp_doc/product_family.tpl' family=$landing.family heading_id='exp-doc-product-family-title'}
</section>
</div>
{include uri='design:parts/doc_edit_link.tpl' node=$node}
{undef $doc_product}
