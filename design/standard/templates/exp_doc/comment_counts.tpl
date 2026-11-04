{* A person's comments for the Contributors page, in both designs: "%count comments, last comment %age ago (%date)",
   the age in years, months or days from the newest comment's written date. Parameters: counts (an entry of fetch
   exp_doc/contributor_list or commenter_list: comments, last_comment). *}
{def $doc_t = $counts.last_comment
     $doc_days = cond( $doc_t, div( sub( currentdate(), $doc_t ), 86400 )|floor, 0 )
     $doc_years = div( $doc_days, 365.25 )|floor
     $doc_months = div( $doc_days, 30.44 )|floor
     $doc_age = cond( ge( $doc_years, 1 ), cond( eq( $doc_years, 1 ), '1 year'|i18n( 'design/exp_doc' ), '%n years'|i18n( 'design/exp_doc', '', hash( '%n', $doc_years ) ) ),
                      ge( $doc_months, 1 ), cond( eq( $doc_months, 1 ), '1 month'|i18n( 'design/exp_doc' ), '%n months'|i18n( 'design/exp_doc', '', hash( '%n', $doc_months ) ) ),
                      cond( eq( $doc_days, 1 ), '1 day'|i18n( 'design/exp_doc' ), '%n days'|i18n( 'design/exp_doc', '', hash( '%n', $doc_days ) ) ) )}
{cond( eq( $counts.comments, 1 ), '1 comment'|i18n( 'design/exp_doc' ), '%count comments'|i18n( 'design/exp_doc', '', hash( '%count', $counts.comments ) ) )}{if $doc_t}, {'last comment %age ago (%date)'|i18n( 'design/exp_doc', '', hash( '%age', $doc_age, '%date', $doc_t|l10n( 'shortdate' ) ) )}{/if}
{undef $doc_t $doc_days $doc_years $doc_months $doc_age}
