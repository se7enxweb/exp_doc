{* One level of a Classic comment thread (parts/doc_comments.tpl): each comment in its row, its replies nested
   inside the row as the static site nested them (fetch exp_doc/comment_children, each comment's replies in their
   stored order, to any depth). The author, date and text are what fetch exp_doc/historical_comment finds
   stored first (author: relation, author_name, the old author, the comment's own markup; text: body, the old text,
   else the comment's own markup original_html). *}
<ul>{foreach $comments as $doc_index => $comment}{def $doc_e = fetch( 'exp_doc', 'historical_comment', hash( 'node_id', $comment.node_id ) )}    <li class="{cond( $doc_index|mod( 2 )|eq( 0 ), 'comment-bglight', 'comment-bgdark' )}"><div class="padding">
    <div class="content-view-line">
<div class="class-comment">

<form method="post" action={'content/action'|ezurl}>

<div id="comment{$comment.node_id}" class="attribute-heading">
<h2>{if and( is_set( $comment.data_map.title ), $comment.data_map.title.has_content )}{$comment.data_map.title.content|wash}{else}{$comment.name|wash}{/if}</h2>
</div>

<div class="attribute-byline float-break">
 <p class="date">{if $doc_e.date}{$doc_e.date|datetime( 'custom', '%l %d %F %Y %g:%i:%s %a' )}{/if}</p>
 <p class="author">{$doc_e.name|wash}</p>
</div>

<div class="attribute-short">
{if $doc_e.body}{$comment.data_map[$doc_e.body].content.output.output_text}{else}{$doc_e.html}{/if}{undef $doc_e}
</div>

<input class="button" type="submit" name="NewButton" value="{'Reply'|i18n( 'design/doc2025' )}" />
<input type="hidden" name="NodeID" value="{$comment.node_id}" />
<input type="hidden" name="ClassIdentifier" value="{$class|wash}" />

<input type="hidden" name="RedirectURIAfterPublish" value="{$page.url_alias|wash}" />

</form>

{def $doc_replies = fetch( 'exp_doc', 'comment_children', hash( 'node_id', $comment.node_id, 'class', $class ) )}
{if $doc_replies|count}
{include uri='design:parts/doc_comment_list.tpl' comments=$doc_replies class=$class page=$page}
{/if}
{undef $doc_replies}
</div>
</div>    </div></li>{/foreach}</ul>
