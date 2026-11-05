{* exphelp/parts/dashboard_report: the "Found an error?" band of the help dashboard: the reporting guide
   (exphelp/report), its security section, and a "new issue" button for every tracker of exphelp.ini. Included by
   exphelp/dashboard.tpl and by the front page of the documentation site (fetch( 'exp_doc', 'help_report' )). Styles:
   stylesheets/exphelp.css (.a4-help-report*); no inline CSS or script.

   Variables: report (the address of the reporting guide, '/exphelp/report' when not given), trackers (key => key,
   label, description, url, new_issue_url; optional). *}
{def $help_rctx = 'kernel/exphelp'
     $help_rurl = cond( and( is_set( $report ), $report ), $report, '/exphelp/report' )}
<section class="a4-help-report" aria-labelledby="help-dash-report">
    <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon a4-bi-exclamation-diamond"></span></span>
    <div>
        <h2 id="help-dash-report">{'Found an error?'|i18n( $help_rctx )}</h2>
        <p>{'Tell us on GitHub: the guide shows which tracker fits, what to include and the system details to copy, without any secrets.'|i18n( $help_rctx )}</p>
        <a class="a4-help-report-security" href={concat( $help_rurl, '#security' )|ezurl}><span class="a4-icon a4-bi-shield-lock" aria-hidden="true"></span>{'A security issue? Report it privately, not in a public issue.'|i18n( $help_rctx )}</a>
    </div>
    <div class="a4-help-report-actions">
        <a class="a4-btn a4-btn-primary" href={$help_rurl|ezurl}><span class="a4-icon a4-bi-list-task" aria-hidden="true"></span>{'How to report an error'|i18n( $help_rctx )}</a>
        {if and( is_set( $trackers ), $trackers )}
        {foreach $trackers as $tracker}
            {if and( is_set( $tracker.new_issue_url ), $tracker.new_issue_url|begins_with( 'https://' ) )}
            <a class="a4-btn" href="{$tracker.new_issue_url|wash}" rel="noopener noreferrer" target="_blank"{if and( is_set( $tracker.description ), $tracker.description|ne( '' ) )} title="{$tracker.description|wash}"{/if}><span class="a4-icon a4-bi-git" aria-hidden="true"></span>{$tracker.label|wash}<span class="a4-sr-only"> {'(new issue on GitHub, opens in a new window)'|i18n( $help_rctx )}</span></a>
            {/if}
        {/foreach}
        {/if}
    </div>
</section>
{undef $help_rctx $help_rurl}
