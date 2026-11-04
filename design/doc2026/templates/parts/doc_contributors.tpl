{* "Contributors" on a Modern page: everyone the page names (its contributors relation list, fetch
   exp_doc/contributors), each linked to the contributor's page, with their roles on this page (author, updated,
   maintainer, commenter) and the dates of those roles. Nothing is drawn when the page names nobody. *}
{def $doc_people = fetch( 'exp_doc', 'contributors', hash( 'node_id', $node.node_id ) )
     $doc_role_names = hash( 'author', 'Author'|i18n( 'design/exp_doc' ), 'updated', 'Updated'|i18n( 'design/exp_doc' ),
                             'maintainer', 'Maintainer'|i18n( 'design/exp_doc' ), 'commenter', 'Commenter'|i18n( 'design/exp_doc' ) )}
{if $doc_people|count}
<section class="exp-doc-contributors" aria-labelledby="exp-doc-contributors-title">
    <h2 id="exp-doc-contributors-title" class="a4-h3">{'Contributors'|i18n( 'design/exp_doc' )}</h2>
    <ul class="a4-plain exp-doc-contributor-list">
    {foreach $doc_people as $doc_person}
        <li>
            {if $doc_person.node}<a href={$doc_person.node.url_alias|ezurl}>{$doc_person.name|wash}</a>{else}{$doc_person.name|wash}{/if}
            {foreach $doc_person.roles as $doc_role}
            <span class="a4-tag exp-doc-role is-{$doc_role}">{$doc_role_names[$doc_role]|wash}{if and( is_set( $doc_person.dates[$doc_role] ), $doc_person.dates[$doc_role] )} <time datetime="{$doc_person.dates[$doc_role]|datetime( 'custom', '%Y-%m-%d' )}">{$doc_person.dates[$doc_role]|l10n( 'shortdate' )}</time>{/if}</span>
            {/foreach}
        </li>
    {/foreach}
    </ul>
</section>
{/if}
{undef $doc_people $doc_role_names}
