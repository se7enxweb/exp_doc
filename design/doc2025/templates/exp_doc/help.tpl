{* A help center page in the Classic design (exp_doc/help): the page in the static site's content frame. The help
   center is a Modern addition; Classic shows it in its own boxes so the frame stays the same. *}
<div class="template-design">
<div class="template-module content-view-full">
<div class="template-object">
<div class="attribute-heading">
<h1>{$help_page.title|wash}</h1>
</div>
{$help_page.html}
<div class="break"></div>
<hr class="hide" />
</div>
</div>
</div>
