{* How long ago a time was, in both designs: "%age ago" in minutes, hours, days, months or years. Parameters: time. *}
{def $doc_s = sub( currentdate(), $time )
     $doc_m = div( $doc_s, 60 )|floor
     $doc_h = div( $doc_s, 3600 )|floor
     $doc_d = div( $doc_s, 86400 )|floor
     $doc_mo = div( $doc_d, 30.44 )|floor
     $doc_y = div( $doc_d, 365.25 )|floor}
{if ge( $doc_y, 1 )}{cond( eq( $doc_y, 1 ), '1 year'|i18n( 'design/exp_doc' ), '%n years'|i18n( 'design/exp_doc', '', hash( '%n', $doc_y ) ) )}{elseif ge( $doc_mo, 1 )}{cond( eq( $doc_mo, 1 ), '1 month'|i18n( 'design/exp_doc' ), '%n months'|i18n( 'design/exp_doc', '', hash( '%n', $doc_mo ) ) )}{elseif ge( $doc_d, 1 )}{cond( eq( $doc_d, 1 ), '1 day'|i18n( 'design/exp_doc' ), '%n days'|i18n( 'design/exp_doc', '', hash( '%n', $doc_d ) ) )}{elseif ge( $doc_h, 1 )}{cond( eq( $doc_h, 1 ), '1 hour'|i18n( 'design/exp_doc' ), '%n hours'|i18n( 'design/exp_doc', '', hash( '%n', $doc_h ) ) )}{else}{cond( le( $doc_m, 1 ), '1 minute'|i18n( 'design/exp_doc' ), '%n minutes'|i18n( 'design/exp_doc', '', hash( '%n', $doc_m ) ) )}{/if}
{undef $doc_s $doc_m $doc_h $doc_d $doc_mo $doc_y}
