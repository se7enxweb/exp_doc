{* exp_doc/landing_partners: "Community and partner distributions" on the page of every product (exp_doc.ini
   [PageDisplaySettings] products), after the products: a card for every distribution of [PartnerSettings] Products[]
   in that order, each with its name (linked to its first link), its Supported badge where its status is one of
   [ModernSettings] SupportedStatuses[], its short text, its facts (the labels of "Choosing a product") and its links
   (exp_doc/product_links.tpl). The data is exp_doc.ini [PartnerProduct_<key>]; every text goes through the
   translation (design/exp_doc), as the texts of "Choosing a product" do. Styles: components.css and exp-doc-choose.css
   (the cards of "Choosing a product"); no inline CSS or script.

   The page of every choice ([PageDisplaySettings] choose) draws it after "Choosing a product" with needs=true(): its
   "How to choose" lines, [PartnerSettings] Needs[] (<key>;<the need it answers>), each linked to its card.

   Variables: badge_class (optional, the Supported badge's classes; default a4-badge is-ok), needs (optional, true:
   the "How to choose" lines). *}
{def $doc_partner_keys = ezini( 'PartnerSettings', 'Products', 'exp_doc.ini' )
     $doc_partner_supported = ezini( 'ModernSettings', 'SupportedStatuses', 'exp_doc.ini' )
     $doc_partner_badge = 'a4-badge is-ok'
     $doc_partner_group = ''
     $doc_partner_links = array()
     $doc_partner_line = array()
     $doc_partner_labels = hash( 'What', 'What it is'|i18n( 'design/exp_doc' ),
                                 'BestFor', 'Best for'|i18n( 'design/exp_doc' ),
                                 'Stack', 'Kernel and stack'|i18n( 'design/exp_doc' ),
                                 'Admin', 'Editing and administration'|i18n( 'design/exp_doc' ),
                                 'Features', 'Key features'|i18n( 'design/exp_doc' ),
                                 'PHP', 'PHP'|i18n( 'design/exp_doc' ),
                                 'Learning', 'Learning curve'|i18n( 'design/exp_doc' ) )}
{if is_set( $badge_class )}{set $doc_partner_badge = $badge_class}{/if}
{if $doc_partner_keys|count}
<section class="exp-doc-landing-section exp-doc-choose exp-doc-partners" aria-labelledby="exp-doc-partners-title">
    <h2 id="exp-doc-partners-title" class="a4-h2">{'Community and partner distributions'|i18n( 'design/exp_doc' )}</h2>
    <p class="exp-doc-partners-lead">{'Ready-made distributions of partners and the community, built on the kernels of the products above.'|i18n( 'design/exp_doc' )}</p>
    <ul class="a4-plain exp-doc-choose-cards{if $doc_partner_keys|count|le( 2 )} is-pair{/if}">
    {foreach $doc_partner_keys as $doc_partner_key}
        {set $doc_partner_group = concat( 'PartnerProduct_', $doc_partner_key )
             $doc_partner_links = array()}
        {if ezini_hasvariable( $doc_partner_group, 'Name', 'exp_doc.ini' )}
        {if ezini_hasvariable( $doc_partner_group, 'Links', 'exp_doc.ini' )}
            {foreach ezini( $doc_partner_group, 'Links', 'exp_doc.ini' ) as $doc_partner_link}
                {set $doc_partner_line = $doc_partner_link|explode( ';' )}
                {if $doc_partner_line|count|ge( 2 )}{set $doc_partner_links = $doc_partner_links|append( hash( 'kind', $doc_partner_line.0, 'url', $doc_partner_line.1, 'external', $doc_partner_line.1|contains( '://' ) ) )}{/if}
            {/foreach}
        {/if}
        <li class="a4-card exp-doc-choose-card exp-doc-partner" id="exp-doc-partner-{$doc_partner_key|wash}">
            <h3 class="exp-doc-choose-name">{if $doc_partner_links|count}<a href={if $doc_partner_links.0.external}"{$doc_partner_links.0.url|wash}" rel="noopener noreferrer"{else}{$doc_partner_links.0.url|ezurl}{/if}>{ezini( $doc_partner_group, 'Name', 'exp_doc.ini' )|wash}</a>{else}{ezini( $doc_partner_group, 'Name', 'exp_doc.ini' )|wash}{/if}{if ezini_hasvariable( $doc_partner_group, 'Status', 'exp_doc.ini' )}{if $doc_partner_supported|contains( ezini( $doc_partner_group, 'Status', 'exp_doc.ini' ) )} <span class="{$doc_partner_badge|wash}">{'Supported'|i18n( 'design/exp_doc' )}</span>{/if}{/if}</h3>
            {if ezini_hasvariable( $doc_partner_group, 'Text', 'exp_doc.ini' )}<p class="exp-doc-partner-text">{ezini( $doc_partner_group, 'Text', 'exp_doc.ini' )|i18n( 'design/exp_doc' )|wash}</p>{/if}
            <dl class="exp-doc-choose-facts">
            {foreach $doc_partner_labels as $doc_partner_fact => $doc_partner_label}
                {if ezini_hasvariable( $doc_partner_group, $doc_partner_fact, 'exp_doc.ini' )}
                <div>
                    <dt>{$doc_partner_label|wash}</dt>
                    <dd>{ezini( $doc_partner_group, $doc_partner_fact, 'exp_doc.ini' )|i18n( 'design/exp_doc' )|wash}</dd>
                </div>
                {/if}
            {/foreach}
            </dl>
            {if $doc_partner_links|count}<p class="exp-doc-partner-links">{include uri='design:exp_doc/product_links.tpl' links=$doc_partner_links}</p>{/if}
        </li>
        {/if}
    {/foreach}
    </ul>
    {if is_set( $needs )}{if and( $needs, ezini_hasvariable( 'PartnerSettings', 'Needs', 'exp_doc.ini' ) )}
    <div class="exp-doc-choose-needs">
        <h3 id="exp-doc-partners-needs-title">{'How to choose'|i18n( 'design/exp_doc' )}</h3>
        <ul class="a4-plain" aria-labelledby="exp-doc-partners-needs-title">
        {foreach ezini( 'PartnerSettings', 'Needs', 'exp_doc.ini' ) as $doc_partner_need}
            {set $doc_partner_line = $doc_partner_need|explode( ';' )
                 $doc_partner_group = concat( 'PartnerProduct_', $doc_partner_line.0 )}
            {if and( $doc_partner_line|count|ge( 2 ), $doc_partner_keys|contains( $doc_partner_line.0 ), ezini_hasvariable( $doc_partner_group, 'Name', 'exp_doc.ini' ) )}
            <li><span>{$doc_partner_line.1|i18n( 'design/exp_doc' )|wash}</span> <span class="exp-doc-choose-arrow" aria-hidden="true">&rarr;</span> <a href="#exp-doc-partner-{$doc_partner_line.0|wash}">{ezini( $doc_partner_group, 'Name', 'exp_doc.ini' )|wash}</a></li>
            {/if}
        {/foreach}
        </ul>
    </div>
    {/if}{/if}
</section>
{/if}
{undef $doc_partner_keys $doc_partner_supported $doc_partner_badge $doc_partner_group $doc_partner_links $doc_partner_line $doc_partner_labels}
