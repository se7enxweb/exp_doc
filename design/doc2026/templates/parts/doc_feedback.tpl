{* "Was this page helpful?" under a Modern page (the owner: Yes/No plus an optional comment, stored as an
   information collection, listed per page in the admin, mailed to the setting's address). The page class carries
   two information collector attributes (exp_doc.ini [ModernSettings] FeedbackAttributes[]: the Yes/No choice and
   the comment); the kernel collects them through content/action and mails them per collect.ini. A page without
   those attributes shows no form. *}
{def $doc_fields = ezini( 'ModernSettings', 'FeedbackAttributes', 'exp_doc.ini' )
     $doc_ok = true()}
{foreach $doc_fields as $doc_field}{if not( is_set( $node.data_map[$doc_field] ) )}{set $doc_ok = false()}{/if}{/foreach}
{if $doc_ok}
<section class="exp-doc-feedback" aria-labelledby="exp-doc-feedback-title">
    <form method="post" action={'content/action'|ezurl} class="exp-doc-feedback-form" data-exp-doc-feedback>
        <h2 id="exp-doc-feedback-title" class="a4-h3">{'Was this page helpful?'|i18n( 'design/exp_doc' )}</h2>
        {foreach $doc_fields as $doc_field}
        <div class="exp-doc-feedback-field">{attribute_view_gui attribute=$node.data_map[$doc_field]}</div>
        {/foreach}
        <input type="hidden" name="ContentNodeID" value="{$node.node_id}">
        <input type="hidden" name="ContentObjectID" value="{$node.contentobject_id}">
        <input type="hidden" name="ViewMode" value="full">
        <button type="submit" class="a4-btn is-primary" name="ActionCollectInformation">{'Send feedback'|i18n( 'design/exp_doc' )}</button>
    </form>
</section>
{/if}
{undef $doc_fields $doc_ok}
