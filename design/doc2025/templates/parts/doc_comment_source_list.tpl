{* One level of a Classic page's historical comments read from its static source (fetch exp_doc/historical_comments
   while the import has not stored them: expDocCommentSource, the importer's parser), in the static markup of
   parts/doc_comment_list.tpl: each comment in its row with its heading, date, author and text, its replies' list
   nested inside the row, to any depth. Parameters: comments, page. *}
<ul>{foreach $comments as $doc_index => $doc_c}    <li class="{cond( $doc_index|mod( 2 )|eq( 0 ), 'comment-bglight', 'comment-bgdark' )}"><div class="padding">
    <div class="content-view-line">
<div class="class-comment">

<form method="post" action={'content/action'|ezurl}>

<div id="comment{$doc_c.id|wash}" class="attribute-heading">
<h2>{$doc_c.title|wash}</h2>
</div>

<div class="attribute-byline float-break">
 <p class="date">{if $doc_c.time}{$doc_c.time|datetime( 'custom', '%l %d %F %Y %g:%i:%s %a' )}{/if}</p>
 <p class="author">{$doc_c.author|wash}</p>
</div>

<div class="attribute-short">
{$doc_c.html}
</div>

<input class="button" type="submit" name="NewButton" value="{'Reply'|i18n( 'design/doc2025' )}" />
<input type="hidden" name="NodeID" value="{$page.node_id}" />
<input type="hidden" name="ClassIdentifier" value="{ezini( 'ClassicSettings', 'CommentClass', 'exp_doc.ini' )|wash}" />

<input type="hidden" name="RedirectURIAfterPublish" value="{$page.url_alias|wash}" />

</form>

{if $doc_c.children|count}
{include uri='design:parts/doc_comment_source_list.tpl' comments=$doc_c.children page=$page}
{/if}
</div>
</div>    </div></li>{/foreach}</ul>
