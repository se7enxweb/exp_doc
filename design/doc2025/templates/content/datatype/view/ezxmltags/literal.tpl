{* A code block in the Classic design, as the static site drew it: <pre class="wordwrap ..."> with one
   <span class="line"> per line (an empty line holds &nbsp;). The static pages' Internet Explorer-only
   "Copy to clipboard" comment is not reproduced. Classification "html" keeps the kernel's behavior: raw output. *}
{if eq( $classification, 'html' )}
{$content}
{else}
<pre class="{cond( $classification|trim|ne( '' ), $classification|wash, 'wordwrap' )}">
{foreach $content|explode( "\n" ) as $doc_line}
<span class="line">{if $doc_line|trim|eq( '' )}&nbsp;{else}{$doc_line|wash( xhtml )}{/if}</span>
{/foreach}
</pre>
{/if}
