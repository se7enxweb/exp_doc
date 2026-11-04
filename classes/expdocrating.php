<?php
/**
 * The recent ratings of the documentation (the front page's "Recent ratings" and the view doc/ratings): the single
 * ratings ezstarrating keeps (ezstarrating_data: created_at, rating, contentobject_id), newest first, each with its
 * page and the page's average and count now (ezstarrating). Who rated is never read: no user id, session key or
 * address leaves the database (the readers' privacy). Only pages a reader may open are listed: visible main nodes,
 * read-checked one by one.
 *
 * Filters (view parameters, all optional): manual and version (node ids: only their pages), range (24h, 7d, 30d, all)
 * and stars (the least stars a rating gave, 1-5).
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocRating
{
    /** @var array cache key => result, for the request */
    protected static $cache = array();

    /**
     * The filters of a request, checked: those of the recent changes (manual, version, range) and stars.
     *
     * @param array $params
     * @return array
     */
    public static function filters( array $params )
    {
        $filters = expDocRecent::filters( array_intersect_key( $params, array( 'manual' => 1, 'version' => 1, 'range' => 1 ) ) );
        if ( isset( $params['stars'] ) && ctype_digit( (string)$params['stars'] ) && (int)$params['stars'] >= 1 && (int)$params['stars'] <= 5 )
        {
            $filters['stars'] = (int)$params['stars'];
        }
        return $filters;
    }

    /**
     * One page of the list and the count of all ratings that match.
     *
     * @param array $filters see filters()
     * @param int $offset
     * @param int $limit
     * @return array array( 'items' => list of array( 'node', 'stars', 'time', 'day', 'average', 'count' ), 'count' => int )
     */
    public static function recent( array $filters, $offset, $limit )
    {
        $key = md5( serialize( array( $filters, (int)$offset, (int)$limit ) ) );
        if ( isset( self::$cache[$key] ) )
        {
            return self::$cache[$key];
        }
        $db = eZDB::instance();
        $where = "FROM ezstarrating_data d, ezcontentobject o, ezcontentobject_tree t, ezstarrating a
                  WHERE o.id = d.contentobject_id AND o.status = 1
                  AND t.contentobject_id = o.id AND t.node_id = t.main_node_id AND t.is_hidden = 0 AND t.is_invisible = 0
                  AND a.contentobject_id = d.contentobject_id AND a.contentobject_attribute_id = d.contentobject_attribute_id";
        $parentID = isset( $filters['version'] ) ? $filters['version'] : ( isset( $filters['manual'] ) ? $filters['manual'] : 0 );
        if ( $parentID )
        {
            $parent = eZContentObjectTreeNode::fetch( (int)$parentID );
            if ( !$parent )
            {
                return self::$cache[$key] = array( 'items' => array(), 'count' => 0 );
            }
            $where .= " AND t.path_string LIKE '" . $db->escapeString( $parent->attribute( 'path_string' ) ) . "%'";
        }
        if ( isset( $filters['range'] ) && isset( expDocRecent::$ranges[$filters['range']] ) && expDocRecent::$ranges[$filters['range']] )
        {
            $where .= " AND d.created_at >= " . ( time() - expDocRecent::$ranges[$filters['range']] );
        }
        if ( isset( $filters['stars'] ) )
        {
            $where .= " AND d.rating >= " . (int)$filters['stars'];
        }
        $count = $db->arrayQuery( "SELECT COUNT(*) AS n " . $where );
        $rows = $db->arrayQuery( "SELECT d.rating, d.created_at, t.node_id, a.rating_average, a.rating_count " . $where
                                 . " ORDER BY d.created_at DESC, d.id DESC",
                                 array( 'offset' => max( 0, (int)$offset ), 'limit' => max( 1, (int)$limit ) ) );
        $items = array();
        foreach ( $rows as $row )
        {
            $node = eZContentObjectTreeNode::fetch( (int)$row['node_id'] );
            if ( !$node instanceof eZContentObjectTreeNode || !$node->canRead() )
            {
                continue;
            }
            $items[] = array( 'node' => $node, 'stars' => (int)$row['rating'], 'time' => (int)$row['created_at'],
                              'day' => date( 'Y-m-d', (int)$row['created_at'] ),
                              'average' => round( (float)$row['rating_average'] * 2 ) / 2, 'count' => (int)$row['rating_count'] );
        }
        return self::$cache[$key] = array( 'items' => $items, 'count' => $count ? (int)$count[0]['n'] : 0 );
    }

    /**
     * The front page's "Recent ratings" (fetch exp_doc/recent_ratings).
     *
     * @param int $limit
     * @return array array( 'result' => entries of recent() )
     */
    public static function latest( $limit )
    {
        $list = self::recent( array(), 0, (int)$limit );
        return array( 'result' => $list['items'] );
    }
}
