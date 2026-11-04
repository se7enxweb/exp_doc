{* "Edit this page" for signed-in users who may edit it (the owner chose the admin edit, not GitHub): a link to
   the admin's edit of the page's object in the current language. Anonymous visitors see nothing. *}
{if $node.object.can_edit}
<p class="exp-doc-edit">
    <a class="a4-btn" href={concat( ezini( 'ModernSettings', 'AdminPrefix', 'exp_doc.ini' ), '/content/edit/', $node.contentobject_id, '/f/', $node.object.current_language )|ezurl}>{'Edit this page'|i18n( 'design/exp_doc' )}</a>
</p>
{/if}
