{* An image embedded in a page, in the Classic design: the bare <img> the static site had inside the alignment div
   (content/datatype/view/ezxmltags/embed.tpl draws the div). The original size is used, so the file name equals the
   static one. *}
{def $doc_image = $object.data_map.image.content.original}
        <img src={$doc_image.url|ezroot} alt="{$object.data_map.alt.content|wash}" />
{undef $doc_image}
