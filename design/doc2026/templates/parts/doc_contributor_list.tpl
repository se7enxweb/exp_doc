{* The Contributors folder's list in the Modern design: everyone with an authoring role (fetch exp_doc/contributor_list), most
   pages first, each in its line view (line/exp_doc_contributor.tpl) with its counts. *}
{def $doc_people = fetch( 'exp_doc', 'contributor_list' )}
<section class="exp-doc-contributor-index" aria-labelledby="exp-doc-contributor-index-title">
    <h2 id="exp-doc-contributor-index-title" class="a4-h2">{'%count contributors'|i18n( 'design/exp_doc', '', hash( '%count', $doc_people|count ) )}</h2>
    <ol class="a4-plain exp-doc-contributor-index-list">
    {foreach $doc_people as $doc_person}
        <li class="a4-card">{include uri='design:parts/doc_contributor_line.tpl' node=$doc_person.node doc_counts=$doc_person}</li>
    {/foreach}
    </ol>
</section>
{undef $doc_people}
{* the people whose only role is the author of historical comments (fetch exp_doc/commenter_list), most comments
   first, at the bottom *}
{def $doc_commenters = fetch( 'exp_doc', 'commenter_list' )}
{if $doc_commenters|count}
<section class="exp-doc-contributor-index exp-doc-commenter-index" aria-labelledby="exp-doc-commenter-index-title">
    <h2 id="exp-doc-commenter-index-title" class="a4-h2">{'Commenters'|i18n( 'design/exp_doc' )} <span class="a4-meta">{'%count people'|i18n( 'design/exp_doc', '', hash( '%count', $doc_commenters|count ) )}</span></h2>
    <ol class="a4-plain exp-doc-contributor-index-list">
    {foreach $doc_commenters as $doc_person}
        <li class="a4-card">{include uri='design:parts/doc_contributor_line.tpl' node=$doc_person.node doc_counts=$doc_person}</li>
    {/foreach}
    </ol>
</section>
{/if}
{undef $doc_commenters}
