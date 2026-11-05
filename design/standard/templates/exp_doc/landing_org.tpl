{* exp_doc/landing_org: the help center's bottom blocks at the end of the front page, below everything the front page
   already shows, in both designs (parts/doc_landing.tpl in Modern, parts/doc_full.tpl in Classic): who makes
   Exponential, how to report an error, the free documentation license, Support Exponential (7x and the Exponential
   Foundation), then a short line to the help center's audiences. Every block is the help dashboard's own part
   (exphelp/parts/*), so the texts and their translations stay in one place; the data comes from the kernel as on the
   dashboard (fetch exp_doc/help_report, exp_doc/help_support; exphelp/license inside license_dashboard.tpl).
   Left out entirely when the help is off. Styles: exphelp.css (.a4-help-*) and the design's .exp-doc-landing-org;
   no inline CSS or script.

   Variables: frame_class (optional, more classes of the frame: a4-page in Classic, whose body is not one), start
   (optional, false: without the "Start where you are" card, exp_doc/landing_start.tpl, which both designs draw higher up:
   Modern below the products, Classic below the static page's current lists), about (optional, false: without "Who
   makes Exponential", which Modern draws above the manuals). *}
{def $doc_org_report = fetch( 'exp_doc', 'help_report' )}
{if $doc_org_report}
{def $doc_org_support = fetch( 'exp_doc', 'help_support' )}
<div class="{if and( is_set( $frame_class ), $frame_class )}{$frame_class|wash} {/if}a4-help-frame exp-doc-landing-org">
    {if first_set( $about, true() )}{include uri='design:exphelp/parts/dashboard_about.tpl' landing_on=ezini( 'LandingSettings', 'Enabled', 'exphelp.ini' )|eq( 'enabled' )}{/if}
    {include uri='design:exphelp/parts/dashboard_report.tpl' report=$doc_org_report.url security=$doc_org_report.security trackers=$doc_org_report.trackers}
    {include uri='design:exphelp/parts/license_dashboard.tpl'}
    {if $doc_org_support}{include uri='design:exphelp/parts/support.tpl' support=$doc_org_support}{/if}
    {if first_set( $start, true() )}{include uri='design:exp_doc/landing_start.tpl'}{/if}
</div>
{undef $doc_org_support}
{/if}
{undef $doc_org_report}
