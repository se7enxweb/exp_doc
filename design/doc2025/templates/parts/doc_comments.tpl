{* The historical comments of a Classic page (the class in exp_doc.ini [ClassicSettings] CommentClass,
   comment_historical: the readers' comments of the old site, replies below the comment they answer, in the order of
   their priority; fetch exp_doc/historical_comments, which gives the comments of the page's static source while the
   import has not stored them: parts/doc_comment_source_list.tpl), in the static site's markup:
   - an ezdoc page: div#comments with the thread (parts/doc_comment_list.tpl), rows alternating comment-bglight /
     comment-bgdark, each with its heading, date, author, text and Reply button, and the "New comment" button;
   - a Confluence page: div#comments-section with "<n> Comment(s)" and ol#page-comments, each comment in its own
     markup from the source (original_html).
   One listed exception: the comments are collapsed by default (the owner): <details class="exp-doc-comments-toggle">
   with the summary "Comments (<n> historical)" around the static block; the check leaves the wrapper out.
   A page without comments: the manual pages of the static site (a class in [ClassicSettings] EmptyCommentsClasses[]
   whose static source starts with one of EmptyCommentsPrefixes[]) drew the empty block, "Comments", "There are no
   comments." and the "New comment" button, so they draw it too; every other page draws nothing, as the static site
   did. *}
{def $doc_hist = fetch( 'exp_doc', 'historical_comments', hash( 'node_id', $node.node_id ) )
     $doc_comment_class = $doc_hist.class
     $doc_comments = $doc_hist.comments}
{if $doc_hist.total}
{def $doc_total = $doc_hist.total
     $doc_confluence = and( is_set( $node.data_map.source_path ), ezini( 'ClassicSettings', 'ConfluencePrefixes', 'exp_doc.ini' )|contains( $node.data_map.source_path.content|explode( '/' ).0 ) )}
<details class="exp-doc-comments-toggle"><summary class="exp-doc-comments-summary">{'Comments (%count historical)'|i18n( 'design/exp_doc', '', hash( '%count', $doc_total ) )}</summary>
{if $doc_confluence}
<div id="comments-section" class="pageSection group">
                <div class="section-header">
            <h2 id="comments-section-title" class="section-title">
                                    {cond( eq( $doc_total, 1 ), '1 Comment', concat( $doc_total, ' Comments' ) )}
                            </h2>
        </div>
{* the anonymous avatar of the static comments (a relative path into the static Confluence files, which this site does
   not have): the design's own image *}
{def $doc_cf_avatar = 's/en_GB/5983/f3e491afc761ac0a6981cfa3dcbc04fc7e88c149.16/_/images/icons/profilepics/anonymous.png"'
     $doc_cf_avatar_url = concat( 'images/confluence/anonymous.svg'|ezdesign( 'no' ), '"' )}
            <ol class="comment-threads top-level" id="page-comments">
{if $doc_comments|count}
{foreach $doc_comments as $comment}
                    <li id="comment-thread-{$comment.data_map.source_comment_id.content|explode( 'comment-' )|implode( '' )|wash}" class="comment-thread">
{$comment.data_map.original_html.content|explode( concat( 'src="../../', $doc_cf_avatar ) )|implode( concat( 'src="', $doc_cf_avatar_url ) )|explode( concat( 'src="../', $doc_cf_avatar ) )|implode( concat( 'src="', $doc_cf_avatar_url ) )}
                    </li>
{/foreach}
{else}
{foreach $doc_hist.source as $doc_c}
                    <li id="comment-thread-{$doc_c.id|wash}" class="comment-thread">
{$doc_c.original|explode( concat( 'src="../../', $doc_cf_avatar ) )|implode( concat( 'src="', $doc_cf_avatar_url ) )|explode( concat( 'src="../', $doc_cf_avatar ) )|implode( concat( 'src="', $doc_cf_avatar_url ) )}
                    </li>
{/foreach}
{/if}
            </ol>
{undef $doc_cf_avatar $doc_cf_avatar_url}
</div>
{else}
<div id="comments" class="class-comment">
<div class="content-view-children">

<h1>{'Comments'|i18n( 'design/doc2025' )}</h1>
<div id="comments-content">
{if $doc_comments|count}{include uri='design:parts/doc_comment_list.tpl' comments=$doc_comments class=$doc_comment_class page=$node}{else}{include uri='design:parts/doc_comment_source_list.tpl' comments=$doc_hist.source page=$node}{/if}
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
{elseif and( ezini( 'ClassicSettings', 'EmptyCommentsClasses', 'exp_doc.ini' )|contains( $node.class_identifier ), is_set( $node.data_map.source_path ) )}
{def $doc_source = $node.data_map.source_path.content|trim
     $doc_empty = false()}
{foreach ezini( 'ClassicSettings', 'EmptyCommentsPrefixes', 'exp_doc.ini' ) as $doc_prefix}
    {if $doc_source|begins_with( $doc_prefix )}{set $doc_empty = true()}{break}{/if}
{/foreach}
{if $doc_empty}
<div id="comments" class="class-comment">
<div class="content-view-children">

<h1>{'Comments'|i18n( 'design/doc2025' )}</h1>
<p>{'There are no comments.'|i18n( 'design/doc2025' )}</p>
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
{undef $doc_source $doc_empty}
{/if}
{undef $doc_hist $doc_comment_class $doc_comments}
