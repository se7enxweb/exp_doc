{* exp_doc/landing_products: the products (fetch exp_doc/products: the containers once they exist, else exp_doc.ini
   [ModernSettings] ProductList[]) as the help center's faded cards, each with its name linked, its Supported badge
   where it applies and its short text. Modern's front page draws the products of [ModernSettings] FrontProductList[]
   with a link to the page of all of them ([ModernSettings] ProductsPath); that page (exp_doc.ini [PageDisplaySettings])
   draws all of them, in both designs. Styles: exphelp.css and the design's .exp-doc-manual* rules (Classic: the
   product box's, doc2025.css .exp-doc-product). No inline CSS or script.

   Variables (all optional): only (the ProductList paths to show, in ProductList order; empty or unset: all),
   more (true: a link to the page of all products when some were left out), heading (false: no "Products" heading,
   the page's own title names the list), list_class (the list's grid; default Modern's exp-doc-manuals), badge_class
   (the Supported badge's classes; default Modern's), starters (true: under each product a "Starter:" line linking to
   the cards of its ready-to-run starters on the same page, exp_doc/landing_starters.tpl: the [StarterSettings]
   Starters[] of Kind distribution whose Product is the product's path; the page of every product only). *}
{def $doc_starters = array()
     $doc_product_starters = array()}
{if and( is_set( $starters ), $starters )}
{foreach ezini( 'StarterSettings', 'Starters', 'exp_doc.ini' ) as $doc_starter_key}
    {if and( ezini_hasvariable( concat( 'Starter_', $doc_starter_key ), 'Name', 'exp_doc.ini' ), ezini_hasvariable( concat( 'Starter_', $doc_starter_key ), 'Product', 'exp_doc.ini' ), ezini_hasvariable( concat( 'Starter_', $doc_starter_key ), 'Kind', 'exp_doc.ini' ) )}
    {if eq( ezini( concat( 'Starter_', $doc_starter_key ), 'Kind', 'exp_doc.ini' ), 'distribution' )}{set $doc_starters = $doc_starters|append( hash( 'key', $doc_starter_key, 'name', ezini( concat( 'Starter_', $doc_starter_key ), 'Name', 'exp_doc.ini' ), 'product', ezini( concat( 'Starter_', $doc_starter_key ), 'Product', 'exp_doc.ini' ) ) )}{/if}
    {/if}
{/foreach}
{/if}
{def $doc_products = fetch( 'exp_doc', 'products' )
     $doc_supported = ezini( 'ModernSettings', 'SupportedStatuses', 'exp_doc.ini' )
     $doc_shown = array()
     $doc_list_class = 'exp-doc-manuals exp-doc-products'
     $doc_badge_class = 'exp-doc-version-badge is-supported'
     $doc_heading = true()
     $doc_more = ''}
{if is_set( $list_class )}{set $doc_list_class = $list_class}{/if}
{if is_set( $badge_class )}{set $doc_badge_class = $badge_class}{/if}
{if is_set( $heading )}{set $doc_heading = $heading}{/if}
{foreach $doc_products as $doc_product}
    {if is_set( $only )}
        {if $only|count|eq( 0 )}{set $doc_shown = $doc_shown|append( $doc_product )}
        {elseif $only|contains( $doc_product.path )}{set $doc_shown = $doc_shown|append( $doc_product )}{/if}
    {else}
        {set $doc_shown = $doc_shown|append( $doc_product )}
    {/if}
{/foreach}
{if is_set( $more )}{if and( $more, $doc_shown|count|lt( $doc_products|count ) )}{set $doc_more = ezini( 'ModernSettings', 'ProductsPath', 'exp_doc.ini' )}{/if}{/if}
{if $doc_shown|count}
<section class="exp-doc-landing-section exp-doc-landing-products{if ne( $doc_more, '' )} is-front{/if}"{if $doc_heading} aria-labelledby="exp-doc-products-title"{else} aria-label="{'Products'|i18n( 'design/exp_doc' )}"{/if}>
    {if $doc_heading}<h2 id="exp-doc-products-title" class="a4-h2">{'Products'|i18n( 'design/exp_doc' )}</h2>{/if}
    {if ne( $doc_more, '' )}<p class="exp-doc-products-lead">{'%shown of the %all products of Exponential, the ones most projects start with.'|i18n( 'design/exp_doc', '', hash( '%shown', $doc_shown|count, '%all', $doc_products|count ) )}</p>{/if}
    <ul class="a4-plain {$doc_list_class|wash}">
    {foreach $doc_shown as $doc_index => $doc_product}
        <li class="{cond( $doc_index|mod( 2 ), 'a4-help-grow', 'a4-help-about' )} exp-doc-manual{if $doc_supported|contains( $doc_product.status )} is-supported{/if}">
            <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon {cond( eq( $doc_product.path, 'exponential' ), 'a4-bi-journal-text', 'a4-bi-box-seam' )}"></span></span>
            <div class="exp-doc-manual-body">
                <h3 class="exp-doc-manual-name"><a href={$doc_product.path|ezurl}>{$doc_product.name|wash}</a>{if $doc_supported|contains( $doc_product.status )} <span class="{$doc_badge_class|wash}">{'Supported'|i18n( 'design/exp_doc' )}</span>{/if}</h3>
                {if $doc_product.text}<p class="exp-doc-manual-summary">{$doc_product.text|wash}</p>{/if}
                {set $doc_product_starters = array()}
                {foreach $doc_starters as $doc_starter}{if eq( $doc_starter.product, $doc_product.path )}{set $doc_product_starters = $doc_product_starters|append( $doc_starter )}{/if}{/foreach}
                {if $doc_product_starters|count}<p class="a4-meta exp-doc-manual-starter"><span>{'Starter:'|i18n( 'design/exp_doc' )}</span> {foreach $doc_product_starters as $doc_starter}<a href="#exp-doc-starter-{$doc_starter.key|wash}">{$doc_starter.name|wash}</a>{delimiter}, {/delimiter}{/foreach}</p>{/if}
            </div>
        </li>
    {/foreach}
    </ul>
    {if ne( $doc_more, '' )}
    <p class="exp-doc-products-more"><a class="a4-btn a4-btn-large" href={$doc_more|ezurl}><span class="a4-icon a4-bi-box-seam" aria-hidden="true"></span> {'View all products'|i18n( 'design/exp_doc' )}</a> <span class="a4-meta">{'All %all products, with their documentation'|i18n( 'design/exp_doc', '', hash( '%all', $doc_products|count ) )}</span></p>
    {/if}
</section>
{/if}
{undef $doc_products $doc_supported $doc_shown $doc_list_class $doc_badge_class $doc_heading $doc_more $doc_starters $doc_product_starters}
