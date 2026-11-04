{* The historical comments of a Classic page (the class in exp_doc.ini [ClassicSettings] CommentClass,
   comment_historical: the readers' comments of the old site, replies below the comment they answer, in the order of
   their priority), in the static site's markup:
   - an ezdoc page: div#comments with the thread (parts/doc_comment_list.tpl), rows alternating comment-bglight /
     comment-bgdark, each with its heading, date, author, text and Reply button, and the "New comment" button;
   - a Confluence page: div#comments-section with "<n> Comment(s)" and ol#page-comments, each comment in its own
     markup from the source (original_html).
   One listed exception: the comments are collapsed by default (the owner): <details class="exp-doc-comments-toggle">
   with the summary "Comments (<n> historical)" around the static block; the check leaves the wrapper out. Nothing is
   drawn when the page has no comments, as the static site did. *}
{def $doc_comment_class = ezini( 'ClassicSettings', 'CommentClass', 'exp_doc.ini' )
     $doc_comments = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                      'class_filter_type', 'include',
                                                      'class_filter_array', array( $doc_comment_class ),
                                                      'sort_by', array( 'priority', true() ) ) )}
{if $doc_comments|count}
{def $doc_total = fetch( 'content', 'tree_count', hash( 'parent_node_id', $node.node_id,
                                                         'class_filter_type', 'include',
                                                         'class_filter_array', array( $doc_comment_class ) ) )
     $doc_confluence = and( is_set( $node.data_map.source_path ), ezini( 'ClassicSettings', 'ConfluencePrefixes', 'exp_doc.ini' )|contains( $node.data_map.source_path.content|explode( '/' ).0 ) )}
<details class="exp-doc-comments-toggle"><summary class="exp-doc-comments-summary">{'Comments (%count historical)'|i18n( 'design/exp_doc', '', hash( '%count', $doc_total ) )}</summary>
{if $doc_confluence}
<div id="comments-section" class="pageSection group">
                <div class="section-header">
            <h2 id="comments-section-title" class="section-title">
                                    {cond( eq( $doc_total, 1 ), '1 Comment', concat( $doc_total, ' Comments' ) )}
                            </h2>
        </div>
            <ol class="comment-threads top-level" id="page-comments">
{foreach $doc_comments as $comment}
                    <li id="comment-thread-{$comment.data_map.source_comment_id.content|explode( 'comment-' )|implode( '' )|wash}" class="comment-thread">
{$comment.data_map.original_html.content}
                    </li>
{/foreach}
            </ol>
</div>
{else}
<div id="comments" class="class-comment">
<div class="content-view-children">

<h1>{'Comments'|i18n( 'design/doc2025' )}</h1>
<div id="comments-content">
{include uri='design:parts/doc_comment_list.tpl' comments=$doc_comments class=$doc_comment_class page=$node}
</div>
<div class="toolbar">

<form method="post" action={'content/action'|ezurl}>
<input class="button" type="submit" name="NewButton" value="{'New comment'|i18n( 'design/doc2025' )}" />
<input type="hidden" name="NodeID" value="{$node.node_id}" />
<input type="hidden" name="RedirectURIAfterPublish" value="{$node.url_alias|wash}" />
<input type="hidden" name="ClassIdentifier" value="{$doc_comment_class|wash}" />
</form>
</div>

</div>
</div>
{/if}
</details>
{undef $doc_total $doc_confluence}
{/if}
{undef $doc_comment_class $doc_comments}
