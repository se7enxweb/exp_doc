{* A contributor in a list, in the Classic design (the Contributors folder's page, a listed exception: the static
   site had no such page): the name linked, and, when the list gives them (doc_counts), the pages they wrote, last
   updated and maintain, and their roles, in the static pages' plain list style. *}
{def $doc_role_names = hash( 'author', 'Author'|i18n( 'design/exp_doc' ), 'updated', 'Updated'|i18n( 'design/exp_doc' ),
                             'maintainer', 'Maintainer'|i18n( 'design/exp_doc' ), 'commenter', 'Commenter'|i18n( 'design/exp_doc' ) )}
<div><a href={$node.url_alias|ezurl}>{$node.name|wash}</a>{if is_set( $doc_counts )} &ndash; {if $doc_counts.total}{'Wrote %written, last updated %updated, maintains %maintained pages'|i18n( 'design/exp_doc', '', hash( '%written', $doc_counts.written, '%updated', $doc_counts.updated, '%maintained', $doc_counts.maintained ) )}{if $doc_counts.comments} {'and %count comments'|i18n( 'design/exp_doc', '', hash( '%count', $doc_counts.comments ) )}{/if}{else}{include uri='design:exp_doc/comment_counts.tpl' counts=$doc_counts}{/if}{if $doc_counts.roles|count} ({foreach $doc_counts.roles as $doc_role}{$doc_role_names[$doc_role]|wash}{delimiter}, {/delimiter}{/foreach}){/if}{/if}</div>
{undef $doc_role_names}
