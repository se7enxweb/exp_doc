{* The historical comments of a Modern page: the readers' comments of the old site (fetch exp_doc/historical_comments:
   comment_historical, or the class before it where the import has not converted the page yet), collapsed by default
   (the owner): a disclosure "Comments (<n> historical)", no script, n counting the page's own thread with every
   reply. Inside, the thread (parts/doc_historical_comment_thread.tpl). Nothing is drawn when the page has none. The
   readers' new comments are a section of their own (parts/doc_page_comments.tpl). *}
{def $doc_hist = fetch( 'exp_doc', 'historical_comments', hash( 'node_id', $node.node_id ) )}
{if $doc_hist.total}
<section class="exp-doc-historical-comments" aria-labelledby="exp-doc-historical-comments-title">
    <details class="exp-doc-historical-toggle">
        <summary><h2 id="exp-doc-historical-comments-title" class="a4-h3">{'Comments (%count historical)'|i18n( 'design/exp_doc', '', hash( '%count', $doc_hist.total ) )}</h2></summary>
        <p class="a4-meta">{'Written by readers of the earlier documentation sites, kept as they were.'|i18n( 'design/exp_doc' )}</p>
        {include uri='design:parts/doc_historical_comment_thread.tpl' parent_id=$node.node_id class=$doc_hist.class depth=1}
    </details>
</section>
{/if}
{undef $doc_hist}
