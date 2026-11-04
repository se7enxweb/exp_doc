{* The readers' comments of a Modern page (a class of exp_doc.ini [CommentSettings] PageClasses[]): the message after
   sending one ((comment)/held: it waits for a moderator), the approved comments as a thread, and the form. New
   comments are held by the kernel's review hold until a moderator releases them (doc/comment, expDocComment). The
   historical comments of the old site are a section of their own (parts/doc_comments.tpl). *}
{if ezini( 'CommentSettings', 'PageClasses', 'exp_doc.ini' )|contains( $node.class_identifier )}
{def $doc_state = cond( and( is_set( $view_parameters ), is_set( $view_parameters.comment ) ), $view_parameters.comment, '' )}
<section class="exp-doc-page-comments" id="exp-doc-comments" aria-labelledby="exp-doc-comments-title">
    <h2 id="exp-doc-comments-title" class="a4-h3">{'Comments'|i18n( 'design/exp_doc' )}</h2>
    {if eq( $doc_state, 'held' )}
    <p class="a4-card exp-doc-comment-status" role="status">{'Thank you. Your comment awaits moderation and appears here once a moderator has approved it.'|i18n( 'design/exp_doc' )}</p>
    {elseif eq( $doc_state, 'published' )}
    <p class="a4-card exp-doc-comment-status" role="status">{'Thank you. Your comment is published.'|i18n( 'design/exp_doc' )}</p>
    {/if}
    {include uri='design:parts/doc_comment_thread.tpl' parent_id=$node.node_id depth=1}
    <details class="exp-doc-comment-add">
        <summary class="a4-btn">{'Add a comment'|i18n( 'design/exp_doc' )}</summary>
        {include uri='design:parts/doc_comment_form.tpl' parent_id=$node.node_id prefix='comment'}
    </details>
</section>
{undef $doc_state}
{/if}
