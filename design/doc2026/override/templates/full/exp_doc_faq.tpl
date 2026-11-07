{* An FAQ group in the Modern design: the page, then its questions (exp_doc_faq_question children) as open-able
   answers, and the FAQPage structured data for search engines (JSON, not a script that runs). *}
{def $doc_questions = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                       'class_filter_type', 'include', 'class_filter_array', array( 'exp_doc_faq_question' ),
                                                       'sort_by', $node.sort_array ) )
     $doc_entities = array()}
{set-block scope=relative variable=doc_after}{if $doc_questions|count}<section class="exp-doc-faq" aria-labelledby="exp-doc-faq-title">
    <h2 id="exp-doc-faq-title" class="a4-h2">{'Questions'|i18n( 'design/exp_doc' )}</h2>
    {foreach $doc_questions as $doc_q}
    <details class="exp-doc-faq-item" id="q{$doc_q.node_id}">
        <summary>{$doc_q.data_map.question.content|wash}</summary>
        <div class="exp-doc-faq-answer">{attribute_view_gui attribute=$doc_q.data_map.answer}</div>
    </details>
    {set $doc_entities = $doc_entities|append( hash( '@type', 'Question', 'name', $doc_q.data_map.question.content,
                                                     'acceptedAnswer', hash( '@type', 'Answer', 'text', $doc_q.data_map.answer.content.output.output_text|explode( '<' )|implode( ' <' )|strip_tags|html_entity_decode|trim ) ) )}
    {/foreach}
</section>
<script type="application/ld+json">{json_encode( hash( '@context', 'https://schema.org', '@type', 'FAQPage', 'mainEntity', $doc_entities ) )}</script>{/if}{/set-block}
{include uri='design:parts/doc_full.tpl' node=$node after_body=$doc_after}
{undef $doc_questions $doc_entities}
