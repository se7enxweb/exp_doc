{* exp_doc/product_links: the buttons of a product's landing page (fetch exp_doc/product_landing, .links: exp_doc.ini
   [ProductLanding_<path>] Links[]), one .a4-btn per link with the label and icon of its kind, the first one primary;
   an address outside the site gets rel="noopener noreferrer". Modern draws them in the hero
   (parts/doc_product_landing.tpl), Classic in the product's box (parts/doc_full.tpl). Styles: components.css only.

   Variables: links. *}
{def $doc_kinds = hash( 'install', hash( 'label', 'Install'|i18n( 'design/exp_doc' ), 'icon', 'download' ),
                        'upgrade', hash( 'label', 'Upgrade'|i18n( 'design/exp_doc' ), 'icon', 'arrow-up-circle' ),
                        'compare', hash( 'label', 'Compare the distributions'|i18n( 'design/exp_doc' ), 'icon', 'signpost-split' ),
                        'source', hash( 'label', 'GitHub', 'icon', 'git' ),
                        'package', hash( 'label', 'Packagist', 'icon', 'box-seam' ),
                        'website', hash( 'label', 'Website'|i18n( 'design/exp_doc' ), 'icon', 'globe2' ) )}
{foreach $links as $doc_index => $doc_link}{if is_set( $doc_kinds[$doc_link.kind] )}
<a class="a4-btn{if eq( $doc_index, 0 )} a4-btn-primary{/if}" href={if $doc_link.external}"{$doc_link.url|wash}" rel="noopener noreferrer"{else}{$doc_link.url|ezurl}{/if}><span class="a4-icon a4-bi-{$doc_kinds[$doc_link.kind].icon}" aria-hidden="true"></span> {$doc_kinds[$doc_link.kind].label|wash}</a>
{/if}{/foreach}
{undef $doc_kinds}
