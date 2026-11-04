{* A tutorial in the Modern design: the page with a summary box before the body (level, duration, prerequisites)
   and its steps (exp_doc_tutorial_step children) as a numbered list after it. *}
{def $doc_map = $node.data_map
     $doc_steps = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                   'class_filter_type', 'include', 'class_filter_array', array( 'exp_doc_tutorial_step' ),
                                                   'sort_by', $node.sort_array ) )}
{set-block scope=relative variable=doc_before}<aside class="a4-card exp-doc-tutorial-box" aria-label="{'About this tutorial'|i18n( 'design/exp_doc' )}">
    <dl class="exp-doc-facts">
    {if $doc_map.level.has_content}<div><dt>{'Level'|i18n( 'design/exp_doc' )}</dt><dd>{$doc_map.level.content|wash}</dd></div>{/if}
    {if $doc_map.duration.has_content}<div><dt>{'Duration'|i18n( 'design/exp_doc' )}</dt><dd>{$doc_map.duration.content|wash}</dd></div>{/if}
    {if $doc_steps|count}<div><dt>{'Steps'|i18n( 'design/exp_doc' )}</dt><dd>{$doc_steps|count}</dd></div>{/if}
    </dl>
    {if $doc_map.prerequisites.has_content}<div class="exp-doc-prerequisites"><h2 class="a4-h3">{'Before you start'|i18n( 'design/exp_doc' )}</h2>{attribute_view_gui attribute=$doc_map.prerequisites}</div>{/if}
</aside>{/set-block}
{set-block scope=relative variable=doc_after}{if $doc_steps|count}<section class="exp-doc-steps" aria-labelledby="exp-doc-steps-title">
    <h2 id="exp-doc-steps-title" class="a4-h2">{'Steps'|i18n( 'design/exp_doc' )}</h2>
    <ol class="exp-doc-step-list">
    {foreach $doc_steps as $doc_step}<li><a href={$doc_step.url_alias|ezurl}>{$doc_step.name|wash}</a></li>{/foreach}
    </ol>
</section>{/if}{/set-block}
{include uri='design:parts/doc_full.tpl' node=$node before_body=$doc_before after_body=$doc_after}
{undef $doc_map $doc_steps}
