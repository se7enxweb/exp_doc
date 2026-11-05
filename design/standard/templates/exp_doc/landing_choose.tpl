{* exp_doc/landing_choose: "Choosing a product" on the front page, a colored box (the help center's .a4-help-support
   with the info fade): one line, a card for every product (what it is, best for, the stack, the administration, the
   key features, PHP and what there is to learn), "How to choose" by need, and the recommendation with its buttons
   (the recommended product's install link and its landing page). Modern draws it right before the products
   (parts/doc_landing.tpl); Classic, which has no products list, at the same place, before "Start where you are"
   (parts/doc_full.tpl). Styles: components.css, exphelp.css and exp-doc-choose.css; no inline CSS or script.

   The data is exp_doc.ini: the products, their names and paths from [ModernSettings] ProductList[] (in that order, the
   ones with a [ChooseProduct_<path, "_" for "/">] group), their facts from those groups, "How to choose" and the
   recommended product from [ChooseSettings]. Every text of the settings goes through the translation (design/exp_doc),
   so the catalogues translate it and a text an editor changed shows in English until its entry is changed too.

   Variables: framed (optional, true: drawn in its own .a4-help-frame), frame_class (optional, more classes of that
   frame: a4-page in Classic, whose body is not one). *}
{if ezini( 'ChooseSettings', 'Enabled', 'exp_doc.ini' )|eq( 'enabled' )}
{def $doc_choose_pick = ezini( 'ChooseSettings', 'Recommended', 'exp_doc.ini' )
     $doc_choose_products = array()
     $doc_choose_names = hash()
     $doc_choose_group = ''
     $doc_choose_line = array()
     $doc_choose_install = ''
     $doc_choose_labels = hash( 'What', 'What it is'|i18n( 'design/exp_doc' ),
                                'BestFor', 'Best for'|i18n( 'design/exp_doc' ),
                                'Stack', 'Kernel and stack'|i18n( 'design/exp_doc' ),
                                'Admin', 'Editing and administration'|i18n( 'design/exp_doc' ),
                                'Features', 'Key features'|i18n( 'design/exp_doc' ),
                                'PHP', 'PHP'|i18n( 'design/exp_doc' ),
                                'Learning', 'Learning curve'|i18n( 'design/exp_doc' ) )}
{foreach ezini( 'ModernSettings', 'ProductList', 'exp_doc.ini' ) as $doc_choose_entry}
    {set $doc_choose_line = $doc_choose_entry|explode( ';' )
         $doc_choose_group = concat( 'ChooseProduct_', $doc_choose_line.0|explode( '/' )|implode( '_' ) )}
    {if ezini_hasvariable( $doc_choose_group, 'What', 'exp_doc.ini' )}
        {set $doc_choose_products = $doc_choose_products|append( hash( 'path', $doc_choose_line.0, 'name', $doc_choose_line.1, 'group', $doc_choose_group ) )
             $doc_choose_names = $doc_choose_names|merge( hash( $doc_choose_line.0, $doc_choose_line.1 ) )}
    {/if}
{/foreach}
{def $doc_choose_links_group = concat( 'ProductLanding_', $doc_choose_pick|explode( '/' )|implode( '_' ) )}
{if ezini_hasvariable( $doc_choose_links_group, 'Links', 'exp_doc.ini' )}
{foreach ezini( $doc_choose_links_group, 'Links', 'exp_doc.ini' ) as $doc_choose_link}
    {set $doc_choose_line = $doc_choose_link|explode( ';' )}
    {if and( eq( $doc_choose_line.0, 'install' ), eq( $doc_choose_install, '' ) )}{set $doc_choose_install = $doc_choose_line.1}{/if}
{/foreach}
{/if}
{if $doc_choose_products|count}
{if and( is_set( $framed ), $framed )}<div class="{if and( is_set( $frame_class ), $frame_class )}{$frame_class|wash} {/if}a4-help-frame exp-doc-landing-choose">{/if}
<section class="a4-help-support exp-doc-landing-section exp-doc-choose" aria-labelledby="exp-doc-choose-title">
    <div class="a4-help-support-head">
        <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon a4-bi-signpost-split"></span></span>
        <div>
            <h2 id="exp-doc-choose-title">{'Choosing a product'|i18n( 'design/exp_doc' )}</h2>
            <p>{'Six products share the name Exponential. Here is how they differ, and which one fits what you need.'|i18n( 'design/exp_doc' )}</p>
        </div>
    </div>

    <ul class="a4-plain exp-doc-choose-cards">
    {foreach $doc_choose_products as $doc_choose_product}
        <li class="a4-card exp-doc-choose-card{if eq( $doc_choose_product.path, $doc_choose_pick )} is-recommended{/if}">
            <h3 class="exp-doc-choose-name"><a href={$doc_choose_product.path|ezurl}>{$doc_choose_product.name|wash}</a>{if eq( $doc_choose_product.path, $doc_choose_pick )} <span class="a4-badge is-accent">{'Recommended'|i18n( 'design/exp_doc' )}</span>{/if}</h3>
            <dl class="exp-doc-choose-facts">
            {foreach $doc_choose_labels as $doc_choose_key => $doc_choose_label}
                {if ezini_hasvariable( $doc_choose_product.group, $doc_choose_key, 'exp_doc.ini' )}
                <div>
                    <dt>{$doc_choose_label|wash}</dt>
                    <dd>{ezini( $doc_choose_product.group, $doc_choose_key, 'exp_doc.ini' )|i18n( 'design/exp_doc' )|wash}</dd>
                </div>
                {/if}
            {/foreach}
            </dl>
        </li>
    {/foreach}
    </ul>

    {if ezini_hasvariable( 'ChooseSettings', 'Needs', 'exp_doc.ini' )}
    <div class="exp-doc-choose-needs">
        <h3 id="exp-doc-choose-needs-title">{'How to choose'|i18n( 'design/exp_doc' )}</h3>
        <ul class="a4-plain" aria-labelledby="exp-doc-choose-needs-title">
        {foreach ezini( 'ChooseSettings', 'Needs', 'exp_doc.ini' ) as $doc_choose_need}
            {set $doc_choose_line = $doc_choose_need|explode( ';' )}
            {if is_set( $doc_choose_names[$doc_choose_line.0] )}
            <li><span>{$doc_choose_line.1|i18n( 'design/exp_doc' )|wash}</span> <span class="exp-doc-choose-arrow" aria-hidden="true">&rarr;</span> <a href={$doc_choose_line.0|ezurl}>{$doc_choose_names[$doc_choose_line.0]|wash}</a></li>
            {/if}
        {/foreach}
        </ul>
        {if ezini( 'ProductLandingSettings', 'CompareURL', 'exp_doc.ini' )|ne( '' )}
        <p class="exp-doc-landing-more"><a href={ezini( 'ProductLandingSettings', 'CompareURL', 'exp_doc.ini' )|ezurl}>{'Which one should I choose?'|i18n( 'design/exp_doc' )}</a></p>
        {/if}
    </div>
    {/if}

    {if is_set( $doc_choose_names[$doc_choose_pick] )}
    <div class="exp-doc-choose-pick">
        <p class="exp-doc-choose-pick-lead"><strong>{'The best user experience and the most features are in Exponential 6, not in Platform, Basic or even DXP.'|i18n( 'design/exp_doc' )}</strong></p>
        <p>{'Not sure? Choose Exponential 6.x today and get started fast.'|i18n( 'design/exp_doc' )}</p>
        <p class="exp-doc-choose-pick-actions">
            {if ne( $doc_choose_install, '' )}<a class="a4-btn a4-btn-primary a4-btn-large" href={if $doc_choose_install|contains( '://' )}"{$doc_choose_install|wash}" rel="noopener noreferrer"{else}{$doc_choose_install|ezurl}{/if}><span class="a4-icon a4-bi-download" aria-hidden="true"></span> {'Install Exponential 6'|i18n( 'design/exp_doc' )}</a>{/if}
            <a class="a4-btn a4-btn-large" href={$doc_choose_pick|ezurl}>{'More about Exponential 6'|i18n( 'design/exp_doc' )}</a>
        </p>
    </div>
    {/if}
</section>
{if and( is_set( $framed ), $framed )}</div>{/if}
{/if}
{undef $doc_choose_pick $doc_choose_products $doc_choose_names $doc_choose_group $doc_choose_line $doc_choose_install $doc_choose_labels $doc_choose_links_group}
{/if}
