{* "Contributors" below a Classic page's byline box: everyone the page names (its contributors relation list, fetch
   exp_doc/contributors), in the byline's own style (div.pageinfo, label, comma-separated names). The static site had
   no such list: it is a listed addition (the class exp-doc-contributors), which the Classic check leaves out. *}
{def $doc_people = fetch( 'exp_doc', 'contributors', hash( 'node_id', $node.node_id ) )
     $doc_names = array()}
{if $doc_people|count}
{foreach $doc_people as $doc_person}{set $doc_names = $doc_names|append( $doc_person.name|wash )}{/foreach}
<div class="pageinfo float-break exp-doc-contributors">
<div class="authors">
<p><label>{'Contributors:'|i18n( 'design/doc2025' )}</label>{$doc_names|implode( ', ' )}</p>
</div></div>
{/if}
{undef $doc_people $doc_names}
