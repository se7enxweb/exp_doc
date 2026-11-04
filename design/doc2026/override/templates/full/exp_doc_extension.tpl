{* An extension's page in the Modern design: a facts box before the body (name, repository, Packagist,
   compatibility, license, status). *}
{def $doc_map = $node.data_map}
{set-block scope=relative variable=doc_before}<aside class="a4-card exp-doc-extension-box" aria-label="{'About this extension'|i18n( 'design/exp_doc' )}">
    <dl class="exp-doc-facts">
    {if $doc_map.extension_name.has_content}<div><dt>{'Extension'|i18n( 'design/exp_doc' )}</dt><dd><code>{$doc_map.extension_name.content|wash}</code></dd></div>{/if}
    {if $doc_map.status.has_content}<div><dt>{'Status'|i18n( 'design/exp_doc' )}</dt><dd><span class="a4-badge">{$doc_map.status.content|wash}</span></dd></div>{/if}
    {if $doc_map.compatibility.has_content}<div><dt>{'Works with'|i18n( 'design/exp_doc' )}</dt><dd>{$doc_map.compatibility.content|wash}</dd></div>{/if}
    {if $doc_map.license.has_content}<div><dt>{'License'|i18n( 'design/exp_doc' )}</dt><dd>{$doc_map.license.content|wash}</dd></div>{/if}
    {if $doc_map.repository.has_content}<div><dt>{'Source'|i18n( 'design/exp_doc' )}</dt><dd><a href="{$doc_map.repository.content|wash}">{$doc_map.repository.content|wash}</a></dd></div>{/if}
    {if $doc_map.packagist.has_content}<div><dt>{'Packagist'|i18n( 'design/exp_doc' )}</dt><dd><a href="{$doc_map.packagist.content|wash}">{$doc_map.packagist.content|wash}</a></dd></div>{/if}
    </dl>
</aside>{/set-block}
{include uri='design:parts/doc_full.tpl' node=$node before_body=$doc_before}
{undef $doc_map}
