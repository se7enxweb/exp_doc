{* The rating of a page in both designs (the page's ezsrrating attribute "rating", extension ezstarrating): the average
   as stars with the count, and five radio buttons in a fieldset to rate (javascript/exp-doc-rating.js posts the choice
   to ezstarrating's ezjscore function ezstarrating::rate and shows the new average). One rating per visitor: the
   extension remembers it in the session (site.ini [eZStarRating], AllowChangeRating=disabled on this site). Readers
   without the right to rate, or a page whose rating is switched off, see the average only. Parameters: node. *}
{if and( is_set( $node.data_map.rating ), $node.data_map.rating.data_int|not )}
{def $doc_attr = $node.data_map.rating
     $doc_rating = $doc_attr.content
     $doc_can = has_access_to_limitation( 'ezjscore', 'call', hash( 'FunctionList', 'ezstarrating_rate' ) )}
<form class="exp-doc-rating" data-exp-rating data-call={'ezjscore/call'|ezurl} data-attribute="{$doc_attr.id}" data-version="{$doc_attr.version}"
      data-thanks="{'Thank you for rating.'|i18n( 'design/exp_doc' )|wash}" data-again="{'You have rated this page already.'|i18n( 'design/exp_doc' )|wash}"
      data-failed="{'The rating could not be saved.'|i18n( 'design/exp_doc' )|wash}" data-numbers="{'%average of 5, %count ratings'|i18n( 'design/exp_doc' )|wash}" data-numbers-one="{'%average of 5, 1 rating'|i18n( 'design/exp_doc' )|wash}">
    <span class="exp-doc-rating-average">{include uri='design:exp_doc/rating_stars.tpl' rating=$doc_rating} <span class="exp-doc-rating-numbers" data-exp-rating-numbers>{if eq( $doc_rating.rating_count, 1 )}{'%average of 5, 1 rating'|i18n( 'design/exp_doc', '', hash( '%average', $doc_rating.rounded_average ) )}{elseif $doc_rating.rating_count}{'%average of 5, %count ratings'|i18n( 'design/exp_doc', '', hash( '%average', $doc_rating.rounded_average, '%count', $doc_rating.rating_count ) )}{else}{'No ratings yet'|i18n( 'design/exp_doc' )}{/if}</span></span>
{if $doc_can}
    <fieldset class="exp-doc-rating-choice" hidden data-exp-rating-choice>
        <legend>{'Rate this page'|i18n( 'design/exp_doc' )}</legend>
        {for 1 to 5 as $doc_n}<input type="radio" class="exp-doc-rating-input" id="exp-doc-rate-{$doc_attr.id}-{$doc_n}" name="rating" value="{$doc_n}"><label class="exp-doc-rating-label" for="exp-doc-rate-{$doc_attr.id}-{$doc_n}"><span class="exp-doc-star is-full" aria-hidden="true"></span><span class="exp-doc-rating-sr">{cond( eq( $doc_n, 1 ), '1 star'|i18n( 'design/exp_doc' ), '%n stars'|i18n( 'design/exp_doc', '', hash( '%n', $doc_n ) ) )}</span></label>{/for}
    </fieldset>
{/if}
    <span class="exp-doc-rating-status" role="status" data-exp-rating-status></span>
</form>
{undef $doc_attr $doc_rating $doc_can}
{/if}
