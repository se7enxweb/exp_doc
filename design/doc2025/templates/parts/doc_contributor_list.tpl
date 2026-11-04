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
{* the people whose only role is the author of historical comments (fetch exp_doc/commenter_list), most comments
   first, at the bottom *}
{def $doc_commenters = fetch( 'exp_doc', 'commenter_list' )}
{if $doc_commenters|count}
<h2>{'Commenters'|i18n( 'design/exp_doc' )} ({'%count people'|i18n( 'design/exp_doc', '', hash( '%count', $doc_commenters|count ) )})</h2>
<ol class="exp-doc-contributor-index">
{foreach $doc_commenters as $doc_person}
<li>{node_view_gui view='line' content_node=$doc_person.node doc_counts=$doc_person}</li>
{/foreach}
</ol>
{/if}
{undef $doc_commenters}
