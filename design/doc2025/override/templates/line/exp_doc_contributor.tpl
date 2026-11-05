{* A contributor in a list, in the Classic design (the Contributors folder's page, a listed exception: the static
   site had no such page): the name linked, and, when the list gives them (doc_counts), the pages they wrote, last
   updated and maintain, and their roles, in the static pages' plain list style. *}
{if is_set( $doc_counts )}{include uri='design:parts/doc_contributor_line.tpl' node=$node doc_counts=$doc_counts}{else}{include uri='design:parts/doc_contributor_line.tpl' node=$node}{/if}
