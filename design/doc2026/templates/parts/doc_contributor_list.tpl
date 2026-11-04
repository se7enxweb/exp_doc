{* The Contributors folder's list in the Modern design: every contributor (fetch exp_doc/contributor_list), most
   pages first, each in its line view (line/exp_doc_contributor.tpl) with its counts. *}
{def $doc_people = fetch( 'exp_doc', 'contributor_list' )}
<section class="exp-doc-contributor-index" aria-labelledby="exp-doc-contributor-index-title">
    <h2 id="exp-doc-contributor-index-title" class="a4-h2">{'%count contributors'|i18n( 'design/exp_doc', '', hash( '%count', $doc_people|count ) )}</h2>
    <ol class="a4-plain exp-doc-contributor-index-list">
    {foreach $doc_people as $doc_person}
        <li class="a4-card">{node_view_gui view='line' content_node=$doc_person.node doc_counts=$doc_person}</li>
    {/foreach}
    </ol>
</section>
{undef $doc_people}
