{* A contributor in a list, in the Modern design: the name linked to the contributor's page, and, when the list gives
   them (doc_counts, an entry of fetch exp_doc/contributor_list or commenter_list), the pages they wrote, last updated
   and maintain, with their roles as tags. The line view (line/exp_doc_contributor.tpl) draws this, and the
   Contributors page (parts/doc_contributor_list.tpl) includes it directly for its ~800 people: a node_view_gui per
   person looks up the override keys (object states, parent, section) with a few queries each. Parameters: node,
   doc_counts (optional). *}
{def $doc_role_names = hash( 'author', 'Author'|i18n( 'design/exp_doc' ), 'updated', 'Updated'|i18n( 'design/exp_doc' ),
                             'maintainer', 'Maintainer'|i18n( 'design/exp_doc' ), 'commenter', 'Commenter'|i18n( 'design/exp_doc' ) )}
<div class="exp-doc-contributor-line">
    <h3 class="exp-doc-contributor-line-name"><a href={$node.url_alias|ezurl}>{$node.name|wash}</a></h3>
{if is_set( $doc_counts )}
    <p class="a4-meta exp-doc-contributor-line-counts">{if $doc_counts.total}{'Wrote %written, last updated %updated, maintains %maintained pages'|i18n( 'design/exp_doc', '', hash( '%written', $doc_counts.written, '%updated', $doc_counts.updated, '%maintained', $doc_counts.maintained ) )}{if $doc_counts.comments} {'and %count comments'|i18n( 'design/exp_doc', '', hash( '%count', $doc_counts.comments ) )}{/if}{else}{include uri='design:exp_doc/comment_counts.tpl' counts=$doc_counts}{/if}</p>
    {if $doc_counts.roles|count}
    <p class="exp-doc-contributor-line-roles">{foreach $doc_counts.roles as $doc_role}<span class="a4-tag exp-doc-role is-{$doc_role}">{$doc_role_names[$doc_role]|wash}</span>{delimiter} {/delimiter}{/foreach}</p>
    {/if}
{/if}
</div>
{undef $doc_role_names}
