{* One level of the readers' comments of a Modern page (parts/doc_page_comments.tpl): each approved comment with its
   author, date, subject and text, a "Reply" disclosure with the reply form (no script: <details>), and its own
   replies indented below it, down to [CommentSettings] MaxDepth levels. Parameters: parent_id, depth. *}
{def $doc_comments = fetch( 'exp_doc', 'comment_thread', hash( 'node_id', $parent_id ) )}
{if $doc_comments|count}
<ol class="a4-plain exp-doc-comment-thread{if gt( $depth, 1 )} is-reply{/if}">
{foreach $doc_comments as $doc_comment}
    {def $doc_c = $doc_comment.data_map}
    <li class="exp-doc-comment" id="comment-{$doc_comment.node_id}">
        <article class="a4-card exp-doc-comment-card" aria-labelledby="comment-{$doc_comment.node_id}-subject">
            <header class="exp-doc-comment-head">
                <h3 class="exp-doc-comment-subject" id="comment-{$doc_comment.node_id}-subject">{$doc_c.subject.content|wash}</h3>
                <p class="a4-meta">{'%name on %date'|i18n( 'design/exp_doc', '', hash( '%name', $doc_c.author.content|wash, '%date', concat( '<time datetime="', $doc_comment.object.published|datetime( 'custom', '%Y-%m-%dT%H:%i' ), '">', $doc_comment.object.published|l10n( 'shortdatetime' ), '</time>' ) ) )}</p>
            </header>
            <div class="exp-doc-comment-text">{$doc_c.message.content|wash|nl2br}</div>
            <details class="exp-doc-comment-reply">
                <summary>{'Reply'|i18n( 'design/exp_doc' )}</summary>
                {include uri='design:parts/doc_comment_form.tpl' parent_id=$doc_comment.node_id prefix=concat( 'reply-', $doc_comment.node_id ) reply=true()}
            </details>
        </article>
        {if lt( $depth, ezini( 'CommentSettings', 'MaxDepth', 'exp_doc.ini' ) )}
        {include uri='design:parts/doc_comment_thread.tpl' parent_id=$doc_comment.node_id depth=inc( $depth )}
        {/if}
    </li>
    {undef $doc_c}
{/foreach}
</ol>
{/if}
{undef $doc_comments}
