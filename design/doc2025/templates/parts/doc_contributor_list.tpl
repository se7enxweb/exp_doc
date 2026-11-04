{* The Contributors folder's list in the Classic design (a listed exception): every contributor (fetch
   exp_doc/contributor_list), most pages first, each in its line view with its counts, as a plain list. *}
{def $doc_people = fetch( 'exp_doc', 'contributor_list' )}
<h2>{'%count contributors'|i18n( 'design/exp_doc', '', hash( '%count', $doc_people|count ) )}</h2>
<ol class="exp-doc-contributor-index">
{foreach $doc_people as $doc_person}
<li>{node_view_gui view='line' content_node=$doc_person.node doc_counts=$doc_person}</li>
{/foreach}
</ol>
{undef $doc_people}
