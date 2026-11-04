{* A rating as five small stars, read only, in both designs (line views, child cards, the rating form's average):
   full, half or empty from the average rounded to a half star; one accessible name for the whole row ("Rated 4.2
   out of 5 by 7 readers"). Parameters: rating (the ezsrrating attribute's content: rating_average, rating_count). *}
{def $doc_avg = cond( is_set( $rating.rating_average ), $rating.rating_average, 0 )
     $doc_halves = mul( $doc_avg, 2 )|round}
<span class="exp-doc-stars" role="img" aria-label="{'Rated %average out of 5 by %count readers'|i18n( 'design/exp_doc', '', hash( '%average', $doc_avg|l10n( 'number' )|explode( '.00' )|implode( '' ), '%count', $rating.rating_count ) )|wash}">{for 1 to 5 as $doc_n}<span class="exp-doc-star {cond( ge( $doc_halves, mul( $doc_n, 2 ) ), 'is-full', eq( $doc_halves, sub( mul( $doc_n, 2 ), 1 ) ), 'is-half', 'is-empty' )}" aria-hidden="true"></span>{/for}</span>
{undef $doc_avg $doc_halves}
