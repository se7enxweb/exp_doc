{* "Written by / Last updated by / Maintainers" under a Classic page, exactly as the static site drew it. The facts
   come from the page's attributes, not its body: written_by and last_updated_by (relations to exp_doc_contributor
   objects), written_at and last_updated_at (dates), maintainers (a relation list). The box is drawn when the page
   has an author; each part only when it has a value. Dates as the static site wrote them: 09/02/2005 10:42 am. *}
{def $doc_map = $node.data_map
     $doc_names = array()}
{if and( is_set( $doc_map.written_by ), $doc_map.written_by.has_content )}<div class="pageinfo float-break">
<div class="created">


<p><label>{'Written by:'|i18n( 'design/doc2025' )}</label>{$doc_map.written_by.content.name|wash}{if and( is_set( $doc_map.written_at ), $doc_map.written_at.has_content )}&nbsp;({$doc_map.written_at.content.timestamp|datetime( 'custom', '%d/%m/%Y %g:%i %a' )}){/if}</p>
</div>
{if and( is_set( $doc_map.last_updated_by ), $doc_map.last_updated_by.has_content )}<div class="modified">
<p><label>{'Last updated by:'|i18n( 'design/doc2025' )}</label>{$doc_map.last_updated_by.content.name|wash}{if and( is_set( $doc_map.last_updated_at ), $doc_map.last_updated_at.has_content )}&nbsp;({$doc_map.last_updated_at.content.timestamp|datetime( 'custom', '%d/%m/%Y %g:%i %a' )}){/if}</p>
</div>{/if}{if and( is_set( $doc_map.maintainers ), $doc_map.maintainers.has_content )}{foreach $doc_map.maintainers.content.relation_list as $doc_rel}{def $doc_obj = fetch( 'content', 'object', hash( 'object_id', $doc_rel.contentobject_id ) )}{if $doc_obj}{set $doc_names = $doc_names|append( $doc_obj.name )}{/if}{undef $doc_obj}{/foreach}<div class="authors">
<p><label>{'Maintainers:'|i18n( 'design/doc2025' )}</label>{$doc_names|implode( ', ' )|wash}</p>
</div>{/if}</div>
{/if}
{undef $doc_map $doc_names}
