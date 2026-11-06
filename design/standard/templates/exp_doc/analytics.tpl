{* The website statistics tag (Google Analytics through Google Tag Manager), only with the reader's consent.
   It takes the place of {'false'|bc_ga_urchin()} in both pagelayouts: that operator (extension bcwebsitestatistics)
   prints the script elements themselves, so Google's tag would load for every reader before any choice. This part
   reads the same settings (bcwebsitestatistics.ini [BCWebsiteStatisticsSettings]: PageSubmit, Urchin, HostName,
   SecureTagManagerScript, else SecureScript / Script) under the same conditions, and prints them as data only:
   - the JSON element #exp-doc-analytics-config: id (Urchin), src (the tag's address as the operator builds it),
     setup (the extension's javascript/bcwebsitestatistics_gtag.js, which configures gtag as before) and udn;
   - javascript/exp-doc-analytics.js, the "analytics" category of the cookie banner (exp_doc/cookie_consent.tpl):
     it loads the two scripts only once the reader has accepted that category, and on later pages while the stored
     choice says so. Rejected, withdrawn or not yet answered: nothing from Google is requested.
   Without the settings (PageSubmit not enabled, Urchin disabled) nothing is printed and the banner offers no
   statistics category. exp_doc/cookie_consent.tpl tests the same conditions for its wording. *}
{def $ga_ini = 'bcwebsitestatistics.ini'
     $ga_id = cond( ezini_hasvariable( 'BCWebsiteStatisticsSettings', 'Urchin', $ga_ini ),
                    ezini( 'BCWebsiteStatisticsSettings', 'Urchin', $ga_ini ), 'disabled' )
     $ga_on = and( ezini_hasvariable( 'BCWebsiteStatisticsSettings', 'PageSubmit', $ga_ini ),
                   eq( ezini( 'BCWebsiteStatisticsSettings', 'PageSubmit', $ga_ini ), 'enabled' ),
                   $ga_id|count|gt( 0 ), ne( $ga_id, 'disabled' ) )}
{if $ga_on}
{def $ga_tm = cond( ezini_hasvariable( 'BCWebsiteStatisticsSettings', 'SecureTagManagerScript', $ga_ini ),
                    ezini( 'BCWebsiteStatisticsSettings', 'SecureTagManagerScript', $ga_ini ), '' )
     $ga_udn = cond( ezini_hasvariable( 'BCWebsiteStatisticsSettings', 'HostName', $ga_ini ),
                     ezini( 'BCWebsiteStatisticsSettings', 'HostName', $ga_ini ), 'disabled' )
     $ga_src = cond( $ga_tm|count|gt( 0 ), concat( $ga_tm, '?id=', $ga_id ),
                     ezini( 'BCWebsiteStatisticsSettings', 'SecureScript', $ga_ini ) )}
<script type="application/json" id="exp-doc-analytics-config">{json_encode( hash( 'id', $ga_id,
                                                                                    'src', $ga_src,
                                                                                    'setup', 'javascript/bcwebsitestatistics_gtag.js'|ezdesign( 'no' ),
                                                                                    'udn', cond( eq( $ga_udn, 'disabled' ), '', $ga_udn ) ) )}</script>
{ezscript_load( array( 'exp-doc-analytics.js' ) )}
{undef $ga_tm $ga_udn $ga_src}
{/if}
{undef $ga_ini $ga_id $ga_on}
