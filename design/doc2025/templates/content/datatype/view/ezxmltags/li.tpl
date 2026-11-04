{* A list item in the Classic design, as the static site drew it: its text in a <div> (the old documentation site
   kept the item's paragraph as a block), "<li><div>...</div></li>". *}
<li{if ne( $classification|trim, '' )} class="{$classification|wash}"{/if}><div>{$content}</div></li>
