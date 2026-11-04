{* One level of a Modern page's historical comments read from its static source (fetch exp_doc/historical_comments
   gives them while the import has not stored them yet: expDocCommentSource, the importer's parser): each with its
   author, date, subject and text as the source has them, then its replies one level deeper, to any depth; drawn as
   parts/doc_historical_comment_thread.tpl draws the stored ones. Parameters: comments, depth, reply_to. *}
{def $doc_indent = ezini( 'CommentSettings', 'IndentDepth', 'exp_doc.ini' )}
<ol class="a4-plain exp-doc-comment-thread{if gt( $depth, 1 )} is-reply{/if}{if gt( $depth, $doc_indent )} is-deep{/if}">
{foreach $comments as $doc_c}
    <li class="exp-doc-comment" id="historical-comment-source-{$doc_c.id|wash}">
        <article class="a4-card exp-doc-comment-card" aria-labelledby="historical-comment-source-{$doc_c.id|wash}-subject">
            <header class="exp-doc-comment-head">
                {if and( gt( $depth, $doc_indent ), is_set( $reply_to ), $reply_to )}<p class="a4-meta exp-doc-comment-replyto">{'Replying to %name'|i18n( 'design/exp_doc', '', hash( '%name', $reply_to|wash ) )}</p>{/if}
                <h3 class="exp-doc-comment-subject" id="historical-comment-source-{$doc_c.id|wash}-subject">{$doc_c.title|wash}</h3>
                <p class="a4-meta">{$doc_c.author|wash}{if and( $doc_c.author, $doc_c.time )} · {/if}{if $doc_c.time}<time datetime="{$doc_c.time|datetime( 'custom', '%Y-%m-%dT%H:%i' )}">{$doc_c.time|l10n( 'shortdatetime' )}</time>{/if}</p>
            </header>
            <div class="exp-doc-comment-text">{$doc_c.html}</div>
        </article>
        {if $doc_c.children|count}
        {include uri='design:parts/doc_historical_source_thread.tpl' comments=$doc_c.children depth=inc( $depth ) reply_to=$doc_c.author}
        {/if}
    </li>
{/foreach}
</ol>
{undef $doc_indent}
