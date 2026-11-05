{* exp_doc/landing_org: the help center's bottom blocks at the end of the front page, below everything the front page
   already shows, in both designs (parts/doc_landing.tpl in Modern, parts/doc_full.tpl in Classic): who makes
   Exponential, how to report an error, the free documentation license, Support Exponential (7x and the Exponential
   Foundation), then a short line to the help center's audiences. Every block is the help dashboard's own part
   (exphelp/parts/*), so the texts and their translations stay in one place; the data comes from the kernel as on the
   dashboard (fetch exp_doc/help_report, exp_doc/help_support; exphelp/license inside license_dashboard.tpl).
   Left out entirely when the help is off. Styles: exphelp.css (.a4-help-*) and the design's .exp-doc-landing-org;
   no inline CSS or script. *}
{def $doc_org_report = fetch( 'exp_doc', 'help_report' )}
{if $doc_org_report}
{def $doc_org_support = fetch( 'exp_doc', 'help_support' )}
<div class="a4-help-frame exp-doc-landing-org">
    {include uri='design:exphelp/parts/dashboard_about.tpl' landing_on=ezini( 'LandingSettings', 'Enabled', 'exphelp.ini' )|eq( 'enabled' )}
    {include uri='design:exphelp/parts/dashboard_report.tpl' report=$doc_org_report.url security=$doc_org_report.security trackers=$doc_org_report.trackers}
    {include uri='design:exphelp/parts/license_dashboard.tpl'}
    {if $doc_org_support}{include uri='design:exphelp/parts/support.tpl' support=$doc_org_support}{/if}
    <section class="a4-card exp-doc-landing-org-start" aria-labelledby="exp-doc-org-start">
        <div class="a4-help-section-head">
            <h2 id="exp-doc-org-start"><span class="a4-icon a4-bi-people" aria-hidden="true"></span>{'Start where you are'|i18n( 'kernel/exphelp' )}</h2>
            <p>{'Pick your role to see the pages written for it.'|i18n( 'kernel/exphelp' )}</p>
            <a href={'exphelp/dashboard#help-dash-audiences'|ezurl}>{'Open the help center'|i18n( 'design/exp_doc' )}</a>
        </div>
    </section>
</div>
{undef $doc_org_support}
{/if}
{undef $doc_org_report}
