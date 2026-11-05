{* A contributor in a list, in the Modern design (the Contributors folder's page): the name linked to the
   contributor's page, and, when the list gives them (doc_counts, an entry of fetch exp_doc/contributor_list), the
   pages they wrote, last updated and maintain, with their roles as tags. *}
{if is_set( $doc_counts )}{include uri='design:parts/doc_contributor_line.tpl' node=$node doc_counts=$doc_counts}{else}{include uri='design:parts/doc_contributor_line.tpl' node=$node}{/if}
