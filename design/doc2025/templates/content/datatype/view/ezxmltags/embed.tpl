{* An embedded object in the Classic design, as the static site drew it: a div with the classes object-left,
   object-center or object-right around the object's embed view. *}
<div class="{if $object_parameters.align}object-{$object_parameters.align}{else}embed{/if}{if ne( $classification|trim, '' )} {$classification|wash}{/if}">
{content_view_gui view=$view link_parameters=$link_parameters object_parameters=$object_parameters content_object=$object classification=$classification}
</div>
