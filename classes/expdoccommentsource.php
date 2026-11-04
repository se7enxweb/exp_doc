<?php
/**
 * The historical comments of a page read straight from its static source file, for the pages whose comments the
 * import has not stored as comment_historical objects yet (the owner: "we have the info", never a placeholder).
 *
 * The parser is the importer's own (exp_static_html_imports, the doc-html type's comments(): ezdoc #comments-content
 * and Confluence's comment threads, with the replies below the comment they answer), on the importer's checkout of the
 * source repository (var/<site>/static-import/doc-html/source) and its rules (statichtmlimport.ini [Type_doc-html]).
 * Each comment comes back as a hash for the templates: title, author, time, html (the text), original (the comment's
 * own markup in the source), id and children.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocCommentSource extends expStaticImportTypeDocHtml
{
    /** @var array source path => comments, for the request */
    protected static $cache = array();

    /**
     * The comments of a static file, as a tree.
     *
     * @param string $sourcePath the page's source_path (relative to the source repository; an anchor is dropped)
     * @return array list of array( 'id', 'title', 'author', 'time', 'html', 'original', 'children' )
     */
    public static function read( $sourcePath )
    {
        $path = preg_replace( '/#.*$/', '', ltrim( (string)$sourcePath, '/' ) );
        if ( $path === '' || strpos( $path, '..' ) !== false || !class_exists( 'expStaticImportEngine' ) )
        {
            return array();
        }
        if ( isset( self::$cache[$path] ) )
        {
            return self::$cache[$path];
        }
        $source = expStaticImportEngine::workDir( 'doc-html' ) . '/source';
        if ( !is_file( $source . '/' . $path ) )
        {
            return self::$cache[$path] = array();
        }
        $parser = new self();
        $parser->configure( expStaticImportRules::load( 'doc-html' ) );
        return self::$cache[$path] = self::shape( $parser->comments( $source, $path ) );
    }

    /**
     * The importer's comment pages as the templates' hashes.
     *
     * @param array $pages
     * @return array
     */
    protected static function shape( array $pages )
    {
        $out = array();
        foreach ( $pages as $page )
        {
            $meta = isset( $page['meta'] ) ? $page['meta'] : array();
            $out[] = array( 'id' => isset( $meta['comment_id'] ) ? (string)$meta['comment_id'] : '',
                            'title' => (string)$page['title'],
                            'author' => isset( $meta['author'] ) ? (string)$meta['author'] : '',
                            'time' => isset( $meta['modified'] ) ? (int)$meta['modified'] : 0,
                            'html' => (string)$page['body_html'],
                            'original' => (string)$page['original_html'],
                            'children' => self::shape( isset( $page['children'] ) ? $page['children'] : array() ) );
        }
        return $out;
    }

    /**
     * How many comments a tree holds, replies included.
     *
     * @param array $comments
     * @return int
     */
    public static function count( array $comments )
    {
        $n = 0;
        foreach ( $comments as $comment )
        {
            $n += 1 + self::count( $comment['children'] );
        }
        return $n;
    }
}
