{* A help center page in the Modern design (exp_doc/help): the page rendered live from its file by the kernel's
   Markdown renderer, in the documentation's article frame; doc2026.js builds the page's contents from its headings.
   A note says where the page comes from. *}
<article class="exp-doc-article exp-doc-help">
    <p class="a4-meta exp-doc-help-source">{'From the help center of this installation'|i18n( 'design/exp_doc' )} · <code>{$help_page.id|wash}</code></p>
    <div class="exp-doc-body" data-exp-doc-body>
{$help_page.html}
    </div>
</article>
