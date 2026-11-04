{* A heading in the Classic design, as the static site drew it: "<a name="eztoc..." id="eztoc..."></a><h2>".
   The anchor is the imported one (the static page's own, kept in the XML as a paragraph before the heading, drawn
   bare by paragraph.tpl), so the kernel's generated toc anchor (eztoc<attribute id>_<n>) is left out. *}
{set $classification = cond( and( is_set( $align ), $align ), concat( $classification, ' text-', $align ), $classification )}
{if is_set( $anchor_name )}<a name="{$anchor_name|wash}" id="{$anchor_name|wash}"></a>{/if}
{switch match=$level}
{case match=2}<h3{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h3>{/case}
{case match=3}<h4{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h4>{/case}
{case match=4}<h5{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h5>{/case}
{case match=5}<h6{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h6>{/case}
{case match=6}<h6{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h6>{/case}
{case}<h2{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h2>{/case}
{/switch}
