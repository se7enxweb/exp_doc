{* "Written by / Last updated by" under a Classic page, as on the static site: shown when the page has an author
   (the imported attributes author and modifier, with source_created and source_modified; the owner kept every
   piece of metadata, author names included). Dates as the static site wrote them: 14/09/2010 10:27 am. *}
{def $doc_map = $node.data_map}
{if and( is_set( $doc_map.author ), $doc_map.author.has_content )}<div class="pageinfo float-break">
<div class="created">


<p><label>{'Written by:'|i18n( 'design/doc2025' )}</label>{$doc_map.author.content|wash}&nbsp;({cond( is_set( $doc_map.source_created ), $doc_map.source_created.content.timestamp, $node.object.published )|datetime( 'custom', '%d/%m/%Y %g:%i %a' )})</p>
</div>
{if and( is_set( $doc_map.modifier ), $doc_map.modifier.has_content )}<div class="modified">
<p><label>{'Last updated by:'|i18n( 'design/doc2025' )}</label>{$doc_map.modifier.content|wash}&nbsp;({cond( is_set( $doc_map.source_modified ), $doc_map.source_modified.content.timestamp, $node.object.modified )|datetime( 'custom', '%d/%m/%Y %g:%i %a' )})</p>
</div>{/if}</div>
{/if}
{undef $doc_map}
