{* An image embedded in a page, in the Classic design: the bare <img> the static site had inside the alignment div
   (content/datatype/view/ezxmltags/embed.tpl draws the div). The original size is used, so the file name equals the
   static one; doc.css keeps it within the page width. The alt text is the object's alt field, else the image's
   alternative text, else the object's name. *}
{def $doc_map = $object.data_map
     $doc_image = $doc_map.image.content.original
     $doc_alt = $object.name}
{if $doc_map.image.content.alternative_text}{set $doc_alt = $doc_map.image.content.alternative_text}{/if}
{if and( is_set( $doc_map.alt ), $doc_map.alt.has_content )}{set $doc_alt = $doc_map.alt.content}{/if}
        <img src={$doc_image.url|ezroot} alt="{$doc_alt|wash}" />
{undef $doc_map $doc_image $doc_alt}
