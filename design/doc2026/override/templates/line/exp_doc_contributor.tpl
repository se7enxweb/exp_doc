{* A contributor in a list, in the Modern design (the Contributors folder's page): the name linked to the
   contributor's page, and, when the list gives them (doc_counts, an entry of fetch exp_doc/contributor_list), the
   pages they wrote, last updated and maintain, with their roles as tags. *}
{def $doc_role_names = hash( 'author', 'Author'|i18n( 'design/exp_doc' ), 'updated', 'Updated'|i18n( 'design/exp_doc' ),
                             'maintainer', 'Maintainer'|i18n( 'design/exp_doc' ) )}
<div class="exp-doc-contributor-line">
    <h3 class="exp-doc-contributor-line-name"><a href={$node.url_alias|ezurl}>{$node.name|wash}</a></h3>
{if is_set( $doc_counts )}
    <p class="a4-meta exp-doc-contributor-line-counts">{'Wrote %written, last updated %updated, maintains %maintained pages'|i18n( 'design/exp_doc', '', hash( '%written', $doc_counts.written, '%updated', $doc_counts.updated, '%maintained', $doc_counts.maintained ) )}</p>
    {if $doc_counts.roles|count}
    <p class="exp-doc-contributor-line-roles">{foreach $doc_counts.roles as $doc_role}<span class="a4-tag exp-doc-role is-{$doc_role}">{$doc_role_names[$doc_role]|wash}</span>{delimiter} {/delimiter}{/foreach}</p>
    {/if}
{/if}
</div>
{undef $doc_role_names}
