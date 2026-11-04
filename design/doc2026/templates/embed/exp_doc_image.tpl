{* An image embedded in a page, in the Modern design: the image at its large size, with its caption and credit
   when it has them. *}
{def $doc_map = $object.data_map
     $doc_image = $doc_map.image.content[ezini( 'ModernSettings', 'EmbedImageAlias', 'exp_doc.ini' )]}
<figure class="exp-doc-figure">
    <img src={$doc_image.url|ezroot} alt="{$doc_map.alt.content|wash}" width="{$doc_image.width}" height="{$doc_image.height}" loading="lazy">
{if or( and( is_set( $doc_map.caption ), $doc_map.caption.has_content ), and( is_set( $doc_map.credit ), $doc_map.credit.has_content ) )}
    <figcaption>{if and( is_set( $doc_map.caption ), $doc_map.caption.has_content )}{attribute_view_gui attribute=$doc_map.caption}{/if}{if and( is_set( $doc_map.credit ), $doc_map.credit.has_content )} <span class="a4-meta">{$doc_map.credit.content|wash}</span>{/if}</figcaption>
{/if}
</figure>
{undef $doc_map $doc_image}
