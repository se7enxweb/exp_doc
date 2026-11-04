{* A paragraph in the Classic design. A paragraph that holds nothing but an anchor (the import keeps the static
   page's "<a name="eztoc..."></a>" before its heading that way) is drawn as the bare anchor, as on the static site;
   every other one as the standard design draws it. *}
{set $classification = cond( and( is_set( $align ), $align ), concat( $classification, ' text-', $align ), $classification )}
{def $doc_text = $content|trim}
{if and( $doc_text|begins_with( '<a name="' ), $doc_text|ends_with( '></a>' ), eq( $doc_text|explode( '<a ' )|count, 2 ) )}{$doc_text}{else}<p{if $classification|trim} class="{$classification|wash}"{/if}>
{if eq( $doc_text, '' )}&nbsp;{else}{$content}{/if}
</p>{/if}
{undef $doc_text}
