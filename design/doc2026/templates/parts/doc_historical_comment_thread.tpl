{* One level of a Modern page's historical comments (parts/doc_historical_comments.tpl): each comment with its author
   (linked to the contributor's page when the import knows them), its date and its text, and its replies indented
   below it, in the order of their priority. What is shown comes from fetch exp_doc/historical_comment, which takes the
   first value stored (author: relation, author_name, the old author, the comment's own markup; text: body, the old
   text, else the comment's own markup original_html). Parameters: parent_id, class, depth. *}
{def $doc_items = fetch( 'content', 'list', hash( 'parent_node_id', $parent_id,
                                                   'class_filter_type', 'include', 'class_filter_array', array( $class ),
                                                   'sort_by', array( 'priority', true() ) ) )}
{if $doc_items|count}
<ol class="a4-plain exp-doc-comment-thread{if gt( $depth, 1 )} is-reply{/if}">
{foreach $doc_items as $doc_item}
    {def $doc_e = fetch( 'exp_doc', 'historical_comment', hash( 'node_id', $doc_item.node_id ) )}
    <li class="exp-doc-comment" id="historical-comment-{$doc_item.node_id}">
        <article class="a4-card exp-doc-comment-card" aria-labelledby="historical-comment-{$doc_item.node_id}-subject">
            <header class="exp-doc-comment-head">
                <h3 class="exp-doc-comment-subject" id="historical-comment-{$doc_item.node_id}-subject">{if and( is_set( $doc_item.data_map.title ), $doc_item.data_map.title.has_content )}{$doc_item.data_map.title.content|wash}{else}{$doc_item.name|wash}{/if}</h3>
                <p class="a4-meta">{if $doc_e.contributor}<a href={$doc_e.contributor.url_alias|ezurl}>{$doc_e.name|wash}</a>{elseif $doc_e.name}{$doc_e.name|wash}{else}{'Unknown author'|i18n( 'design/exp_doc' )}{/if}{if $doc_e.date} · <time datetime="{$doc_e.date|datetime( 'custom', '%Y-%m-%dT%H:%i' )}">{$doc_e.date|l10n( 'shortdatetime' )}</time>{/if}</p>
            </header>
            <div class="exp-doc-comment-text">{if $doc_e.body}{attribute_view_gui attribute=$doc_item.data_map[$doc_e.body]}{elseif $doc_e.html}{$doc_e.html}{else}<p class="a4-meta">{'The text of this comment was not kept.'|i18n( 'design/exp_doc' )}</p>{/if}</div>
        </article>
        {if lt( $depth, ezini( 'CommentSettings', 'MaxDepth', 'exp_doc.ini' ) )}
        {include uri='design:parts/doc_historical_comment_thread.tpl' parent_id=$doc_item.node_id class=$class depth=inc( $depth )}
        {/if}
    </li>
    {undef $doc_e}
{/foreach}
</ol>
{/if}
{undef $doc_items}
