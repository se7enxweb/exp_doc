{* One level of a Modern page's historical comments (parts/doc_historical_comments.tpl), drawn as a tree: the comments
   directly below parent_id (fetch exp_doc/comment_children, in their stored order), each with its author (linked to
   the contributor's page when the import knows them), its date and its text (fetch exp_doc/historical_comment), then
   its own replies, one level deeper, to any depth. Each level below the first is indented with a thread line;
   from [CommentSettings] IndentDepth on, a phone keeps the indent it has and the reply says whom it answers
   ("Replying to <author>"). Parameters: parent_id, class, depth, reply_to (the author of the comment above). *}
{def $doc_items = fetch( 'exp_doc', 'comment_children', hash( 'node_id', $parent_id, 'class', $class ) )
     $doc_indent = ezini( 'CommentSettings', 'IndentDepth', 'exp_doc.ini' )}
{if $doc_items|count}
<ol class="a4-plain exp-doc-comment-thread{if gt( $depth, 1 )} is-reply{/if}{if gt( $depth, $doc_indent )} is-deep{/if}">
{foreach $doc_items as $doc_item}
    {def $doc_e = fetch( 'exp_doc', 'historical_comment', hash( 'node_id', $doc_item.node_id ) )}
    <li class="exp-doc-comment" id="historical-comment-{$doc_item.node_id}">
        <article class="a4-card exp-doc-comment-card" aria-labelledby="historical-comment-{$doc_item.node_id}-subject">
            <header class="exp-doc-comment-head">
                {if and( gt( $depth, $doc_indent ), is_set( $reply_to ), $reply_to )}<p class="a4-meta exp-doc-comment-replyto">{'Replying to %name'|i18n( 'design/exp_doc', '', hash( '%name', $reply_to|wash ) )}</p>{/if}
                <h3 class="exp-doc-comment-subject" id="historical-comment-{$doc_item.node_id}-subject">{if and( is_set( $doc_item.data_map.title ), $doc_item.data_map.title.has_content )}{$doc_item.data_map.title.content|wash}{else}{$doc_item.name|wash}{/if}</h3>
                <p class="a4-meta">{if $doc_e.contributor}<a href={$doc_e.contributor.url_alias|ezurl}>{$doc_e.name|wash}</a>{elseif $doc_e.name}{$doc_e.name|wash}{else}{'Unknown author'|i18n( 'design/exp_doc' )}{/if}{if $doc_e.date} · <time datetime="{$doc_e.date|datetime( 'custom', '%Y-%m-%dT%H:%i' )}">{$doc_e.date|l10n( 'shortdatetime' )}</time>{/if}</p>
            </header>
            <div class="exp-doc-comment-text">{if $doc_e.body}{attribute_view_gui attribute=$doc_item.data_map[$doc_e.body]}{elseif $doc_e.html}{$doc_e.html}{else}<p class="a4-meta">{'The text of this comment was not kept.'|i18n( 'design/exp_doc' )}</p>{/if}</div>
        </article>
        {include uri='design:parts/doc_historical_comment_thread.tpl' parent_id=$doc_item.node_id class=$class depth=inc( $depth )
                 reply_to=cond( $doc_e.name, $doc_e.name, 'Unknown author'|i18n( 'design/exp_doc' ) )}
    </li>
    {undef $doc_e}
{/foreach}
</ol>
{/if}
{undef $doc_items $doc_indent}
