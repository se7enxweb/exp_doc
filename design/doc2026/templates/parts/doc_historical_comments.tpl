{* The historical comments of a Modern page: the readers' comments of the old site (exp_doc.ini [ClassicSettings]
   CommentClass, comment_historical), collapsed by default (the owner): a disclosure "Comments (<n> historical)", no
   script. Inside, the thread (parts/doc_historical_comment_thread.tpl). Nothing is drawn when the page has none. The
   readers' new comments are a section of their own (parts/doc_page_comments.tpl). *}
{def $doc_class = ezini( 'ClassicSettings', 'CommentClass', 'exp_doc.ini' )
     $doc_total = fetch( 'content', 'tree_count', hash( 'parent_node_id', $node.node_id,
                                                         'class_filter_type', 'include', 'class_filter_array', array( $doc_class ) ) )}
{* until the import has replaced them, the comments of the class before (exp_doc.ini CommentClassBefore) *}
{if and( $doc_total|not, ezini( 'ClassicSettings', 'CommentClassBefore', 'exp_doc.ini' ) )}
    {set $doc_class = ezini( 'ClassicSettings', 'CommentClassBefore', 'exp_doc.ini' )
         $doc_total = fetch( 'content', 'tree_count', hash( 'parent_node_id', $node.node_id,
                                                             'class_filter_type', 'include', 'class_filter_array', array( $doc_class ) ) )}
{/if}
{if $doc_total}
<section class="exp-doc-historical-comments" aria-labelledby="exp-doc-historical-comments-title">
    <details class="exp-doc-historical-toggle">
        <summary><h2 id="exp-doc-historical-comments-title" class="a4-h3">{'Comments (%count historical)'|i18n( 'design/exp_doc', '', hash( '%count', $doc_total ) )}</h2></summary>
        <p class="a4-meta">{'Written by readers of the earlier documentation sites, kept as they were.'|i18n( 'design/exp_doc' )}</p>
        {include uri='design:parts/doc_historical_comment_thread.tpl' parent_id=$node.node_id class=$doc_class depth=1}
    </details>
</section>
{/if}
{undef $doc_class $doc_total}
