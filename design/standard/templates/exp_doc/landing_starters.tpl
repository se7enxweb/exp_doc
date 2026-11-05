{* exp_doc/landing_starters: "Starter distributions", the ready-to-run installations, on the page of every product (exp_doc.ini
   [PageDisplaySettings] products) after the products and on the page of every choice ([PageDisplaySettings] choose)
   after "Choosing a product"; never on the front page. A card for every starter of [StarterSettings] Starters[] in that
   order, each with its name (linked to its first link), its newest release tag (or "Template repository" for a
   starter of Kind template), the product it starts (linked to the product's landing page, its name from [ModernSettings]
   ProductList[]), the partner distribution it is the ready-to-run copy of (linked to that card in "Community and partner
   distributions"), its short text, its facts, its commands as code (never translated, one line each) and its links
   (exp_doc/product_links.tpl). The data is exp_doc.ini [Starter_<key>]; every text goes through the translation
   (design/exp_doc). Styles: components.css and exp-doc-choose.css (the cards of "Choosing a product" and of the partner
   distributions); no inline CSS or script.

   Each card has the id exp-doc-starter-<key>: the products' "Starter:" lines (exp_doc/landing_products.tpl with
   starters=true()) and the partner card's "Ready-to-run starter" button link to it.

   Variables: needs (optional, true: the "How to choose" lines, [StarterSettings] Needs[] (<key>;<the need it answers>),
   each linked to its card). *}
{def $doc_starter_keys = ezini( 'StarterSettings', 'Starters', 'exp_doc.ini' )
     $doc_starter_group = ''
     $doc_starter_links = array()
     $doc_starter_line = array()
     $doc_starter_names = hash()
     $doc_starter_product = ''
     $doc_starter_partner = ''
     $doc_starter_labels = hash( 'What', 'What it is'|i18n( 'design/exp_doc' ),
                                 'Starts', 'Product and kernel'|i18n( 'design/exp_doc' ),
                                 'BestFor', 'Best for'|i18n( 'design/exp_doc' ),
                                 'Stack', 'Stack and database'|i18n( 'design/exp_doc' ),
                                 'PHP', 'PHP'|i18n( 'design/exp_doc' ),
                                 'Run', 'How to get it running'|i18n( 'design/exp_doc' ),
                                 'Learning', 'Learning curve'|i18n( 'design/exp_doc' ) )}
{foreach ezini( 'ModernSettings', 'ProductList', 'exp_doc.ini' ) as $doc_starter_entry}
    {set $doc_starter_line = $doc_starter_entry|explode( ';' )}
    {if $doc_starter_line|count|ge( 2 )}{set $doc_starter_names = $doc_starter_names|merge( hash( $doc_starter_line.0, $doc_starter_line.1 ) )}{/if}
{/foreach}
{if $doc_starter_keys|count}
<section class="exp-doc-landing-section exp-doc-choose exp-doc-partners exp-doc-starters" aria-labelledby="exp-doc-starters-title">
    <h2 id="exp-doc-starters-title" class="a4-h2">{'Starter distributions'|i18n( 'design/exp_doc' )}</h2>
    <p class="exp-doc-partners-lead">{'Ready-to-run installations, one GitHub repository each: the Composer vendor directory is included and SQLite is set up, so a clone is most of the installation. The static site starter is a template for static publishing, not a product.'|i18n( 'design/exp_doc' )}</p>
    <ul class="a4-plain exp-doc-choose-cards">
    {foreach $doc_starter_keys as $doc_starter_key}
        {set $doc_starter_group = concat( 'Starter_', $doc_starter_key )
             $doc_starter_links = array()
             $doc_starter_product = ''
             $doc_starter_partner = ''}
        {if ezini_hasvariable( $doc_starter_group, 'Name', 'exp_doc.ini' )}
        {if ezini_hasvariable( $doc_starter_group, 'Links', 'exp_doc.ini' )}
            {foreach ezini( $doc_starter_group, 'Links', 'exp_doc.ini' ) as $doc_starter_link}
                {set $doc_starter_line = $doc_starter_link|explode( ';' )}
                {if $doc_starter_line|count|ge( 2 )}{set $doc_starter_links = $doc_starter_links|append( hash( 'kind', $doc_starter_line.0, 'url', $doc_starter_line.1, 'external', $doc_starter_line.1|contains( '://' ) ) )}{/if}
            {/foreach}
        {/if}
        {if ezini_hasvariable( $doc_starter_group, 'Product', 'exp_doc.ini' )}{set $doc_starter_product = ezini( $doc_starter_group, 'Product', 'exp_doc.ini' )}{/if}
        {if ezini_hasvariable( $doc_starter_group, 'Partner', 'exp_doc.ini' )}{set $doc_starter_partner = ezini( $doc_starter_group, 'Partner', 'exp_doc.ini' )}{/if}
        <li class="a4-card exp-doc-choose-card exp-doc-starter" id="exp-doc-starter-{$doc_starter_key|wash}">
            <h3 class="exp-doc-choose-name">{if $doc_starter_links|count}<a href={if $doc_starter_links.0.external}"{$doc_starter_links.0.url|wash}" rel="noopener noreferrer"{else}{$doc_starter_links.0.url|ezurl}{/if}>{ezini( $doc_starter_group, 'Name', 'exp_doc.ini' )|wash}</a>{else}{ezini( $doc_starter_group, 'Name', 'exp_doc.ini' )|wash}{/if}
            {if and( ezini_hasvariable( $doc_starter_group, 'Kind', 'exp_doc.ini' ), eq( ezini( $doc_starter_group, 'Kind', 'exp_doc.ini' ), 'template' ) )} <span class="a4-badge">{'Template repository'|i18n( 'design/exp_doc' )}</span>
            {elseif and( ezini_hasvariable( $doc_starter_group, 'Version', 'exp_doc.ini' ), ne( ezini( $doc_starter_group, 'Version', 'exp_doc.ini' ), '' ) )} <span class="a4-badge">{'Release %version'|i18n( 'design/exp_doc', '', hash( '%version', ezini( $doc_starter_group, 'Version', 'exp_doc.ini' ) ) )|wash}</span>{/if}</h3>
            {if is_set( $doc_starter_names[$doc_starter_product] )}<p class="exp-doc-starter-for"><span>{cond( and( ezini_hasvariable( $doc_starter_group, 'Kind', 'exp_doc.ini' ), eq( ezini( $doc_starter_group, 'Kind', 'exp_doc.ini' ), 'template' ) ), 'A template for'|i18n( 'design/exp_doc' ), 'Starts'|i18n( 'design/exp_doc' ) )|wash}</span> <a href={$doc_starter_product|ezurl}>{$doc_starter_names[$doc_starter_product]|wash}</a></p>{/if}
            {if and( ne( $doc_starter_partner, '' ), ezini_hasvariable( concat( 'PartnerProduct_', $doc_starter_partner ), 'Name', 'exp_doc.ini' ) )}<p class="exp-doc-starter-for"><span>{'The ready-to-run copy of the partner distribution'|i18n( 'design/exp_doc' )}</span> <a href="#exp-doc-partner-{$doc_starter_partner|wash}">{ezini( concat( 'PartnerProduct_', $doc_starter_partner ), 'Name', 'exp_doc.ini' )|wash}</a></p>{/if}
            {if ezini_hasvariable( $doc_starter_group, 'Text', 'exp_doc.ini' )}<p class="exp-doc-partner-text">{ezini( $doc_starter_group, 'Text', 'exp_doc.ini' )|i18n( 'design/exp_doc' )|wash}</p>{/if}
            <dl class="exp-doc-choose-facts">
            {foreach $doc_starter_labels as $doc_starter_fact => $doc_starter_label}
                {if ezini_hasvariable( $doc_starter_group, $doc_starter_fact, 'exp_doc.ini' )}
                <div>
                    <dt>{$doc_starter_label|wash}</dt>
                    <dd>{ezini( $doc_starter_group, $doc_starter_fact, 'exp_doc.ini' )|i18n( 'design/exp_doc' )|wash}</dd>
                </div>
                {/if}
                {if and( eq( $doc_starter_fact, 'Run' ), ezini_hasvariable( $doc_starter_group, 'Commands', 'exp_doc.ini' ) )}{if ezini( $doc_starter_group, 'Commands', 'exp_doc.ini' )|count}
                <div>
                    <dt>{'Commands from the README'|i18n( 'design/exp_doc' )}</dt>
                    <dd><code class="exp-doc-starter-commands">{foreach ezini( $doc_starter_group, 'Commands', 'exp_doc.ini' ) as $doc_starter_command}<span>{$doc_starter_command|wash}</span>{/foreach}</code></dd>
                </div>
                {/if}{/if}
            {/foreach}
            </dl>
            {if $doc_starter_links|count}<p class="exp-doc-partner-links">{include uri='design:exp_doc/product_links.tpl' links=$doc_starter_links}</p>{/if}
        </li>
        {/if}
    {/foreach}
    </ul>
    {if is_set( $needs )}{if and( $needs, ezini_hasvariable( 'StarterSettings', 'Needs', 'exp_doc.ini' ) )}
    <div class="exp-doc-choose-needs">
        <h3 id="exp-doc-starters-needs-title">{'How to choose a starter'|i18n( 'design/exp_doc' )}</h3>
        <ul class="a4-plain" aria-labelledby="exp-doc-starters-needs-title">
        {foreach ezini( 'StarterSettings', 'Needs', 'exp_doc.ini' ) as $doc_starter_need}
            {set $doc_starter_line = $doc_starter_need|explode( ';' )
                 $doc_starter_group = concat( 'Starter_', $doc_starter_line.0 )}
            {if and( $doc_starter_line|count|ge( 2 ), $doc_starter_keys|contains( $doc_starter_line.0 ), ezini_hasvariable( $doc_starter_group, 'Name', 'exp_doc.ini' ) )}
            <li><span>{$doc_starter_line.1|i18n( 'design/exp_doc' )|wash}</span> <span class="exp-doc-choose-arrow" aria-hidden="true">&rarr;</span> <a href="#exp-doc-starter-{$doc_starter_line.0|wash}">{ezini( $doc_starter_group, 'Name', 'exp_doc.ini' )|wash}</a></li>
            {/if}
        {/foreach}
        </ul>
    </div>
    {/if}{/if}
</section>
{/if}
{undef $doc_starter_keys $doc_starter_group $doc_starter_links $doc_starter_line $doc_starter_names $doc_starter_product $doc_starter_partner $doc_starter_labels}
