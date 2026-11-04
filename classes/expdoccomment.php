<?php
/**
 * Readers' comments on the documentation pages (the view doc/comment, exp_doc.ini [CommentSettings]).
 *
 * A comment is an object of the kernel's comment class (a container, so a reply sits below the comment it answers),
 * created and published with the kernel's publish operation as the reader who sends it. Moderation is the kernel's
 * own: the review hold's auto-hold (content.ini [ReviewHoldSettings] of the site siteaccess) puts the first
 * publication of a reader's comment into review_hold/held and hides its location, so no page, fetch, feed or search
 * shows it; a moderator releases it in Dashboard > Recent content (moderation/recent), which reveals it.
 *
 * Spam protection: the form token (ezformtoken checks every POST), a honeypot field that people leave empty, and a
 * rate limit per address (the kernel's expRequestThresholdCounter, with the address as the request classifier's
 * salted hash, never stored as it is).
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocComment
{
    /** submit() results */
    const HELD = 'held';
    const PUBLISHED = 'published';
    const IGNORED = 'ignored';
    const INVALID = 'invalid';
    const LIMITED = 'limited';
    const REFUSED = 'refused';
    const FAILED = 'failed';

    /**
     * Checks a submission and returns the errors (field => message), empty when it may be stored.
     *
     * @param array $input name, email, subject, message
     * @return array
     */
    public static function errors( array $input )
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $errors = array();
        $name = trim( (string)$input['name'] );
        $message = trim( (string)$input['message'] );
        if ( $name === '' )
        {
            $errors['name'] = ezpI18n::tr( 'design/exp_doc', 'Please give your name.' );
        }
        elseif ( mb_strlen( $name ) > (int)$ini->variable( 'CommentSettings', 'NameLength' ) )
        {
            $errors['name'] = ezpI18n::tr( 'design/exp_doc', 'The name is too long.' );
        }
        if ( trim( (string)$input['email'] ) !== '' && !eZMail::validate( trim( (string)$input['email'] ) ) )
        {
            $errors['email'] = ezpI18n::tr( 'design/exp_doc', 'The e-mail address is not valid.' );
        }
        if ( mb_strlen( trim( (string)$input['subject'] ) ) > (int)$ini->variable( 'CommentSettings', 'SubjectLength' ) )
        {
            $errors['subject'] = ezpI18n::tr( 'design/exp_doc', 'The subject is too long.' );
        }
        if ( mb_strlen( $message ) < 3 )
        {
            $errors['message'] = ezpI18n::tr( 'design/exp_doc', 'Please write your comment.' );
        }
        elseif ( mb_strlen( $message ) > (int)$ini->variable( 'CommentSettings', 'MessageLength' ) )
        {
            $errors['message'] = ezpI18n::tr( 'design/exp_doc', 'The comment is too long.' );
        }
        return $errors;
    }

    /**
     * Whether a node takes comments: a page of [CommentSettings] PageClasses[], or a comment below one.
     *
     * @param eZContentObjectTreeNode $node
     * @return bool
     */
    public static function takesComments( eZContentObjectTreeNode $node )
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $class = $node->attribute( 'class_identifier' );
        if ( in_array( $class, (array)$ini->variable( 'CommentSettings', 'PageClasses' ), true ) )
        {
            return true;
        }
        return $class === $ini->variable( 'CommentSettings', 'Class' ) && self::page( $node ) !== null;
    }

    /**
     * The page a comment belongs to: the nearest ancestor (or the node itself) that is not a comment.
     *
     * @param eZContentObjectTreeNode $node
     * @return eZContentObjectTreeNode|null
     */
    public static function page( eZContentObjectTreeNode $node )
    {
        $commentClass = eZINI::instance( 'exp_doc.ini' )->variable( 'CommentSettings', 'Class' );
        while ( $node instanceof eZContentObjectTreeNode && $node->attribute( 'class_identifier' ) === $commentClass )
        {
            $node = $node->fetchParent();
        }
        return $node instanceof eZContentObjectTreeNode ? $node : null;
    }

    /**
     * Counts one submission of the current address and tells whether it is over the limit.
     *
     * @return bool true when the address sent more than [CommentSettings] RateLimit in the window
     */
    public static function overLimit()
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $ip = eZSys::clientIP();
        $counter = new expRequestThresholdCounter( eZSys::cacheDirectory() . '/exp_doc/comment-rate', (int)$ini->variable( 'CommentSettings', 'RateWindow' ) );
        $key = expRequestClassifier::instance()->ipKey( $ip === false ? '' : $ip );
        return $counter->hit( $key ) > (int)$ini->variable( 'CommentSettings', 'RateLimit' );
    }

    /**
     * Stores a comment below $parent as the current user and publishes it with the kernel's operation (the review
     * hold's auto-hold decides whether it is shown). The caller has checked the form token, the honeypot and the
     * rate limit.
     *
     * @param eZContentObjectTreeNode $parent a page or a comment
     * @param array $input name, email, subject, message
     * @return array array( 'status' => HELD|PUBLISHED|REFUSED|FAILED, 'object' => eZContentObject|null )
     */
    public static function submit( eZContentObjectTreeNode $parent, array $input )
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $class = eZContentClass::fetchByIdentifier( $ini->variable( 'CommentSettings', 'Class' ) );
        if ( !$class || !self::takesComments( $parent )
             || $parent->checkAccess( 'create', $class->attribute( 'id' ), $parent->attribute( 'contentclass_id' ) ) != 1 )
        {
            return array( 'status' => self::REFUSED, 'object' => null );
        }
        $subject = trim( (string)$input['subject'] );
        $message = trim( (string)$input['message'] );
        if ( $subject === '' )
        {
            $subject = mb_substr( preg_replace( '/\s+/u', ' ', $message ), 0, 60 );
        }
        $attributes = array( 'subject' => $subject, 'author' => trim( (string)$input['name'] ), 'message' => $message );
        if ( trim( (string)$input['email'] ) !== '' )
        {
            $attributes['email'] = trim( (string)$input['email'] );
        }
        $object = eZContentFunctions::createAndPublishObject( array( 'class_identifier' => $class->attribute( 'identifier' ),
                                                                    'parent_node_id' => $parent->attribute( 'node_id' ),
                                                                    'creator_id' => eZUser::currentUserID(),
                                                                    'attributes' => $attributes ) );
        if ( !$object instanceof eZContentObject )
        {
            return array( 'status' => self::FAILED, 'object' => null );
        }
        $held = class_exists( 'expReviewHold' ) && expReviewHold::isHeld( $object );
        if ( $held )
        {
            self::notify( $object, $parent );
        }
        return array( 'status' => $held ? self::HELD : self::PUBLISHED, 'object' => $object );
    }

    /**
     * Mails the notice of a comment that waits for moderation: the page, the name, the subject and the message,
     * and where to release it (Dashboard > Recent content). The e-mail address the reader gave is not in it.
     *
     * @param eZContentObject $object
     * @param eZContentObjectTreeNode $parent
     * @return bool
     */
    public static function notify( eZContentObject $object, eZContentObjectTreeNode $parent )
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $recipient = trim( (string)$ini->variable( 'CommentSettings', 'Recipient' ) );
        if ( $recipient === '' )
        {
            $recipient = trim( (string)$ini->variable( 'DocSettings', 'FeedbackRecipient' ) );
        }
        if ( $recipient === '' )
        {
            $recipient = (string)eZINI::instance()->variable( 'MailSettings', 'AdminEmail' );
        }
        if ( !eZMail::validate( $recipient ) )
        {
            eZDebug::writeWarning( 'No valid recipient for the comment notice', __METHOD__ );
            return false;
        }
        $page = self::page( $parent );
        $host = 'https://' . eZSys::hostname();
        $pageUrl = $page ? $page->attribute( 'url_alias' ) : '';
        eZURI::transformURI( $pageUrl );
        $map = $object->dataMap();
        $body = ezpI18n::tr( 'design/exp_doc', 'A comment on the documentation waits for moderation.' ) . "\n\n"
              . ezpI18n::tr( 'design/exp_doc', 'Page' ) . ': ' . ( $page ? $page->attribute( 'name' ) : '' ) . "\n" . $host . $pageUrl . "\n"
              . ezpI18n::tr( 'design/exp_doc', 'Name' ) . ': ' . $map['author']->toString() . "\n"
              . ezpI18n::tr( 'design/exp_doc', 'Subject' ) . ': ' . $map['subject']->toString() . "\n\n"
              . $map['message']->toString() . "\n\n"
              . ezpI18n::tr( 'design/exp_doc', 'Release or delete it in the administration: Dashboard > Recent content, filter "Held".' ) . "\n";
        $mail = new eZMail();
        $mail->setSender( (string)$ini->variable( 'CommentSettings', 'Sender' ) );
        $mail->setReceiver( $recipient );
        $mail->setSubject( ezpI18n::tr( 'design/exp_doc', 'Comment waiting: %subject', null, array( '%subject' => $map['subject']->toString() ) ) );
        $mail->setBody( $body );
        return (bool)eZMailTransport::send( $mail );
    }

    /**
     * The historical comments of a page (exp_doc.ini [ClassicSettings] CommentClass, else CommentClassBefore where
     * the page has none of it yet): the class, the comments directly below the page in the order of their priority,
     * and how many there are with every reply. Only the page's own thread counts, never the comments of its
     * subpages.
     *
     * @param int $nodeID
     * @return array array( 'result' => array( 'class' => string, 'comments' => eZContentObjectTreeNode[], 'total' => int ) )
     */
    public static function historical( $nodeID )
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $classes = array_filter( array( (string)$ini->variable( 'ClassicSettings', 'CommentClass' ),
                                        $ini->hasVariable( 'ClassicSettings', 'CommentClassBefore' ) ? (string)$ini->variable( 'ClassicSettings', 'CommentClassBefore' ) : '' ) );
        foreach ( $classes as $class )
        {
            $comments = eZContentObjectTreeNode::subTreeByNodeID( array( 'Depth' => 1, 'DepthOperator' => 'eq',
                                                                        'ClassFilterType' => 'include', 'ClassFilterArray' => array( $class ),
                                                                        'SortBy' => array( 'priority', true ) ), (int)$nodeID );
            if ( !is_array( $comments ) || !$comments )
            {
                continue;
            }
            $total = count( $comments );
            foreach ( $comments as $comment )
            {
                // replies sit below the comment they answer, so everything of the class below a comment is a reply
                $total += (int)eZContentObjectTreeNode::subTreeCountByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( $class ) ),
                                                                                $comment->attribute( 'node_id' ) );
            }
            return array( 'result' => array( 'class' => $class, 'comments' => $comments, 'total' => $total ) );
        }
        return array( 'result' => array( 'class' => reset( $classes ), 'comments' => array(), 'total' => 0 ) );
    }

    /**
     * What a historical comment shows, whichever class and whatever the import stored:
     *   - name: the author relation's contributor, else author_name, else the old class's author, else the name in
     *     the comment's own markup (original_html: Confluence h4.author, ezdoc p.author);
     *   - contributor: the contributor's node, or false;
     *   - date: created (0 when the import did not store it);
     *   - body: the identifier of the XML attribute with content (body, the old class's text), or '' when there is
     *     none; then html: original_html, the comment's own markup, to show as it was.
     *
     * @param int $nodeID
     * @return array array( 'result' => array( 'name', 'contributor', 'date', 'body', 'html' ) )
     */
    public static function historicalEntry( $nodeID )
    {
        $node = eZContentObjectTreeNode::fetch( (int)$nodeID );
        $entry = array( 'name' => '', 'contributor' => false, 'date' => 0, 'body' => '', 'html' => '' );
        if ( !$node instanceof eZContentObjectTreeNode )
        {
            return array( 'result' => $entry );
        }
        $map = $node->dataMap();
        $has = function ( $identifier ) use ( $map )
        {
            return isset( $map[$identifier] ) && $map[$identifier]->hasContent();
        };
        $html = $has( 'original_html' ) ? (string)$map['original_html']->attribute( 'data_text' ) : '';
        if ( $has( 'author' ) && $map['author']->attribute( 'data_type_string' ) === 'ezobjectrelation' )
        {
            $person = eZContentObject::fetch( (int)$map['author']->attribute( 'data_int' ) );
            if ( $person instanceof eZContentObject )
            {
                $entry['contributor'] = $person->mainNode() ?: false;
                $entry['name'] = $person->attribute( 'name' );
            }
        }
        if ( $has( 'author_name' ) )
        {
            $entry['name'] = trim( $map['author_name']->toString() );
        }
        elseif ( $entry['name'] === '' && $has( 'author' ) && $map['author']->attribute( 'data_type_string' ) === 'ezstring' )
        {
            $entry['name'] = trim( $map['author']->toString() );
        }
        if ( $entry['name'] === '' && $html !== ''
             && preg_match( '#<(?:h4|p)[^>]*class="[^"]*\bauthor\b[^"]*"[^>]*>(.*?)</(?:h4|p)>#si', $html, $match ) )
        {
            $entry['name'] = trim( html_entity_decode( strip_tags( $match[1] ), ENT_QUOTES, 'UTF-8' ) );
        }
        // the date the reader wrote it; never the import's publication date, which would look like a date of 2026
        $entry['date'] = $has( 'created' ) ? (int)$map['created']->attribute( 'data_int' ) : 0;
        foreach ( array( 'body', 'text' ) as $identifier )
        {
            if ( $has( $identifier ) )
            {
                $entry['body'] = $identifier;
                break;
            }
        }
        if ( $entry['body'] === '' )
        {
            $entry['html'] = $html;
        }
        return array( 'result' => $entry );
    }

    /**
     * The newest comments of the site, for the front page's "Recent comments" and the view doc/comments: the
     * readers' comments ([CommentSettings] Class) that a moderator approved (held ones are hidden by the review hold,
     * and checked once more), and with type "all" the historical ones too. Filters (view parameters, all optional):
     * manual and version (node ids: only their pages' comments), range (24h, 7d, 30d, all), type (readers, all).
     *
     * @param array $filters
     * @param int $offset
     * @param int $limit
     * @return array array( 'items' => list of array( 'node', 'page', 'subject', 'excerpt', 'name', 'date', 'type',
     *               'anchor' ), 'count' => int )
     */
    public static function recent( array $filters, $offset, $limit )
    {
        $ini = eZINI::instance( 'exp_doc.ini' );
        $classes = array( (string)$ini->variable( 'CommentSettings', 'Class' ) );
        if ( isset( $filters['type'] ) && $filters['type'] === 'all' )
        {
            $classes[] = (string)$ini->variable( 'ClassicSettings', 'CommentClass' );
        }
        $parentID = (int)eZINI::instance( 'content.ini' )->variable( 'NodeSettings', 'RootNode' );
        if ( isset( $filters['version'] ) )
        {
            $parentID = (int)$filters['version'];
        }
        elseif ( isset( $filters['manual'] ) )
        {
            $parentID = (int)$filters['manual'];
        }
        $params = array( 'ClassFilterType' => 'include', 'ClassFilterArray' => $classes, 'SortBy' => array( 'published', false ),
                         'MainNodeOnly' => true );
        if ( isset( $filters['range'] ) && isset( expDocRecent::$ranges[$filters['range']] ) && expDocRecent::$ranges[$filters['range']] )
        {
            $params['AttributeFilter'] = array( array( 'published', '>=', time() - expDocRecent::$ranges[$filters['range']] ) );
        }
        $count = (int)eZContentObjectTreeNode::subTreeCountByNodeID( $params, $parentID );
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array_merge( $params, array( 'Offset' => (int)$offset, 'Limit' => (int)$limit ) ), $parentID );
        $items = array();
        foreach ( is_array( $nodes ) ? $nodes : array() as $node )
        {
            $object = $node->object();
            if ( class_exists( 'expReviewHold' ) && expReviewHold::isHeld( $object ) )
            {
                continue;
            }
            $map = $node->dataMap();
            $reader = $node->attribute( 'class_identifier' ) === $classes[0];
            if ( $reader )
            {
                $text = isset( $map['message'] ) ? $map['message']->toString() : '';
                $name = isset( $map['author'] ) ? $map['author']->toString() : '';
                $date = (int)$object->attribute( 'published' );
            }
            else
            {
                $entry = self::historicalEntry( $node->attribute( 'node_id' ) );
                $entry = $entry['result'];
                $text = $entry['body'] ? $map[$entry['body']]->attribute( 'data_text' ) : $entry['html'];
                $name = $entry['name'];
                $date = $entry['date'];
            }
            $text = trim( preg_replace( '/\s+/u', ' ', html_entity_decode( strip_tags( str_replace( '<', ' <', (string)$text ) ), ENT_QUOTES, 'UTF-8' ) ) );
            $length = (int)eZINI::instance( 'exp_doc.ini' )->variable( 'RecentSettings', 'ExcerptLength' );
            $items[] = array( 'node' => $node, 'page' => self::page( $node ), 'subject' => $node->attribute( 'name' ),
                              'excerpt' => mb_strlen( $text ) > $length ? rtrim( mb_substr( $text, 0, $length ) ) . '…' : $text,
                              'name' => $name, 'date' => $date, 'type' => $reader ? 'reader' : 'historical',
                              'anchor' => ( $reader ? 'comment-' : 'historical-comment-' ) . $node->attribute( 'node_id' ) );
        }
        return array( 'items' => $items, 'count' => $count );
    }

    /**
     * The front page's "Recent comments" (fetch exp_doc/recent_comments): the newest approved readers' comments.
     *
     * @param int $limit
     * @return array array( 'result' => entries of recent() )
     */
    public static function recentList( $limit )
    {
        $list = self::recent( array(), 0, (int)$limit );
        return array( 'result' => $list['items'] );
    }

    /**
     * The visible comments below a node (a page or a comment), oldest first, as the reader may see them (held ones
     * are hidden by the auto-hold, so readers never get them).
     *
     * @param int $nodeID
     * @return array array( 'result' => eZContentObjectTreeNode[] )
     */
    public static function thread( $nodeID )
    {
        $class = eZINI::instance( 'exp_doc.ini' )->variable( 'CommentSettings', 'Class' );
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array( 'Depth' => 1, 'DepthOperator' => 'eq',
                                                                 'ClassFilterType' => 'include', 'ClassFilterArray' => array( $class ),
                                                                 'SortBy' => array( 'published', true ) ), (int)$nodeID );
        return array( 'result' => is_array( $nodes ) ? $nodes : array() );
    }
}
