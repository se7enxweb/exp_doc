{* The custom tag doc_code (an imported code macro): a code block, its language as a class for the highlighter. *}
<pre class="exp-doc-pre{if and( is_set( $lang ), $lang )} lang-{$lang|wash}{/if}">{$content}</pre>
