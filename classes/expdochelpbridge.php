<?php
/**
 * The help center bridge of the documentation site: a page of the installation's help center (the kernel's doc/
 * Markdown and the active extensions' doc/ folders), rendered live from its file by the kernel's Markdown renderer,
 * with its links and images kept on this site (exp_doc/help and exp_doc/helpfile) instead of the administration's
 * help viewer.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocHelpBridge
{
    /**
     * A help page for the template: array( 'id', 'title', 'html', 'toc', 'path' ) or null when the id is not a page
     * of the help center (or the file fails the help center's checks).
     *
     * @param string $id
     * @return array|null
     */
    public static function page( $id )
    {
        $index = expHelpDocumentIndex::instance();
        $document = $index->document( $id );
        if ( $document === null )
        {
            return null;
        }
        $source = $index->body( $id );
        if ( $source === null )
        {
            return null;
        }
        $renderer = new expHelpMarkdownRenderer( array( 'link_resolver' => array( __CLASS__, 'link' ),
                                                        'image_resolver' => array( __CLASS__, 'image' ),
                                                        'source_path' => isset( $document['path'] ) ? (string)$document['path'] : '' ) );
        $markdown = isset( $document['suffix'] ) && in_array( $document['suffix'], array( 'md', 'markdown' ), true );
        $rendered = $markdown ? $renderer->render( $source, $id ) : $renderer->renderPlainText( $source, $id );
        $title = isset( $document['title'] ) && $document['title'] !== '' ? $document['title']
                                                                           : ( $rendered['title'] !== '' ? $rendered['title'] : $id );
        $path = array( array( 'url' => 'exp_doc/help', 'text' => ezpI18n::tr( 'design/exp_doc', 'Help center' ) ),
                       array( 'url' => false, 'text' => $title ) );
        return array( 'id' => $id, 'title' => $title, 'html' => $rendered['html'], 'toc' => $rendered['toc'], 'path' => $path );
    }

    /**
     * The renderer's link resolver: another help page or image to this site's bridge views, an external link as it
     * is, anything else (a page not in the help center) to no link.
     *
     * @param string $href
     * @param string $currentId
     * @return string|null
     */
    public static function link( $href, $currentId = '' )
    {
        $href = trim( (string)$href );
        if ( $href === '' )
        {
            return null;
        }
        if ( $href[0] === '#' || preg_match( '#^(https?:)?//#i', $href ) || preg_match( '#^mailto:#i', $href ) )
        {
            return expHelpLinks::link( $href, $currentId );
        }
        $anchor = '';
        if ( ( $hash = strpos( $href, '#' ) ) !== false )
        {
            $anchor = '#' . rawurlencode( rawurldecode( substr( $href, $hash + 1 ) ) );
            $href = substr( $href, 0, $hash );
        }
        $id = expHelpLinks::resolveId( preg_replace( '/\?.*$/', '', $href ), $currentId );
        if ( $id === null )
        {
            return null;
        }
        $index = expHelpDocumentIndex::instance();
        if ( $index->document( $id ) !== null )
        {
            return self::url( 'exp_doc/help/' . $id ) . $anchor;
        }
        return $index->asset( $id ) !== null ? self::url( 'exp_doc/helpfile/' . $id ) : null;
    }

    /**
     * The renderer's image resolver: an image of the help center through exp_doc/helpfile, with its size so the page
     * keeps its room while it loads; an https image as it is.
     *
     * @param string $src
     * @param string $currentId
     * @return array|string|null
     */
    public static function image( $src, $currentId = '' )
    {
        $src = trim( (string)$src );
        if ( preg_match( '#^https://#i', $src ) )
        {
            return $src;
        }
        $id = expHelpLinks::resolveId( preg_replace( '/[?#].*$/', '', $src ), $currentId );
        $file = $id === null ? null : expHelpDocumentIndex::instance()->asset( $id );
        if ( $file === null )
        {
            return null;
        }
        $url = self::url( 'exp_doc/helpfile/' . $id );
        $size = is_file( $file ) ? @getimagesize( $file ) : false;
        return is_array( $size ) && !empty( $size[0] ) ? array( 'url' => $url, 'width' => (int)$size[0], 'height' => (int)$size[1] ) : $url;
    }

    /**
     * A site address for a module path, as ezurl gives it (the site's prefix, no index.php when rewritten).
     *
     * @param string $path
     * @return string
     */
    protected static function url( $path )
    {
        $path = implode( '/', array_map( 'rawurlencode', explode( '/', $path ) ) );
        eZURI::transformURI( $path );
        return $path;
    }
}
