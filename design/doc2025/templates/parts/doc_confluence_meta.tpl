{* The byline of a page imported from the Confluence space, in the static Confluence markup
   (div.page-metadata > li.page-metadata-modification-info): "Created by A, last modified by B on Oct 28, 2016",
   "Created and last modified by A on …" when both are the same person, "Created by A on …" when there is no
   update. The names link the contributors' pages; the dates are written_at and last_updated_at. *}
{def $doc_map = $node.data_map
     $doc_author = cond( and( is_set( $doc_map.written_by ), $doc_map.written_by.has_content ), $doc_map.written_by.content, false() )
     $doc_editor = cond( and( is_set( $doc_map.last_updated_by ), $doc_map.last_updated_by.has_content ), $doc_map.last_updated_by.content, false() )
     $doc_date = cond( and( is_set( $doc_map.last_updated_at ), $doc_map.last_updated_at.has_content ), $doc_map.last_updated_at.content.timestamp,
                       and( is_set( $doc_map.written_at ), $doc_map.written_at.has_content ), $doc_map.written_at.content.timestamp, 0 )}
{if $doc_author}
    <div class="page-metadata">
        <ul>
                        <li class="page-metadata-modification-info">
{if and( $doc_editor, ne( $doc_editor.id, $doc_author.id ) )}
            Created by <span class='author'>     <a href={$doc_author.main_node.url_alias|ezurl}
                       class="url fn"
                            >{$doc_author.name|wash}</a></span>, last modified by <span class='editor'>     <a href={$doc_editor.main_node.url_alias|ezurl}
                       class="url fn"
                            >{$doc_editor.name|wash}</a></span>{if $doc_date} on <a class='last-modified' title='Show changes'>{$doc_date|datetime( 'custom', '%M %d, %Y' )}</a>{/if}
{elseif $doc_editor}
            Created and last modified by <span class='author'>     <a href={$doc_author.main_node.url_alias|ezurl}
                       class="url fn"
                            >{$doc_author.name|wash}</a></span>{if $doc_date} on <a class='last-modified' title='Show changes'>{$doc_date|datetime( 'custom', '%M %d, %Y' )}</a>{/if}
{else}
            Created by <span class='author'>     <a href={$doc_author.main_node.url_alias|ezurl}
                       class="url fn"
                            >{$doc_author.name|wash}</a></span>{if $doc_date} on <a class='last-modified' title='Show changes'>{$doc_date|datetime( 'custom', '%M %d, %Y' )}</a>{/if}
{/if}
                </li>
        </ul>
    </div>
{/if}
{undef $doc_map $doc_author $doc_editor $doc_date}
