<?php
// Filter für must-log-in Text: Punkt entfernen, Uppercase
add_filter('comment_form_defaults', function($defaults) {
    if (isset($defaults['must_log_in'])) {
        $text = $defaults['must_log_in'];
        // Entferne jegliche Links
        $text = preg_replace('/<a [^>]*>(.*?)<\/a>/i', '$1', $text);
        // Entferne Punkt am Ende, auch vor schließendem HTML-Tag
        $text = preg_replace('/\.(?=(<\/\w+>)*\s*$)/', '', $text);
        // Füge Leerzeichen nach 'BE' und nach 'IN' ein (nur wenn sie direkt vor 'LOGGED' oder 'TO' stehen)
        $text = preg_replace('/\bBE(?=LOGGED)/', 'BE ', $text);
        $text = preg_replace('/\bIN(?=TO)/', 'IN ', $text);
        $defaults['must_log_in'] = strtoupper($text);
    }
    return $defaults;
});
?>
<?php
if (post_password_required()) {
    return;
}
?>

<div id="comments" class="comments-area">

    <?php if (have_comments()) : ?>
        <ol class="comment-list">
            <?php
            wp_list_comments(array(
                'style'      => 'ol',
                'short_ping' => true,
                'avatar_size'=> 50,
                'callback'   => 'custom_comment_format'
            ));
            ?>
        </ol>
        <?php the_comments_navigation(); ?>
    <?php endif; ?>

    <?php
    if (!comments_open()) {
        echo '<p class="no-comments">Kommentare sind geschlossen.</p>';
    }

    comment_form(array(
        'title_reply'          => '',
        'title_reply_to'       => '',
        'logged_in_as'         => '',
        'comment_notes_before' => '',
        'comment_notes_after'  => '',
        'class_submit'         => 'custom-submit-button',
        'label_submit'         => 'Post Comment',
        'fields' => array(
            'author' => '',
            'email'  => '',
            'url'    => ''
        ),
        'comment_field' => '
            <label for="comment" style="
                margin: 7px 0px 0px 0px;
                padding: 5px 0 4px 0;
                background-color: #09222C;
                border-style: solid;
                border-width: 2px;
                border-color: #0B1924;
                border-radius: 5px;
                color: rgb(237, 210, 57);
                font-family: \'chelsea market\', fantasy;
                font-size: 17px;
                font-weight: 100;
                text-transform: uppercase;
                text-align: center;
                display: block;
            ">Write Comment</label>
            <textarea id="comment" name="comment" cols="45" rows="8" required="required"
                placeholder="Write your comment here..."
                style="
                    width: 100%;
                    background-color: #0E2D38;
                    color: #CCCCCC;
                    border: 2px solid #0B1924;
                    border-radius: 5px;
                    padding: 10px;
                    margin-bottom: 1px;
                    margin-top: 7px;
                    margin-left: 0px;
                    margin-right: 4px;
                    font-family: Questrial, sans-serif;
                    font-size: 15px;
                "
            ></textarea>'
    ));
    ?>
</div>

<style>
/* Entferne "↪" bei Child-Kommentaren */
#comments ol.comment-list .children:before {
    content: none !important;
    display: none !important;
}

/* Verstecke den comment-reply-title */
.comment-reply-title {
    display: none !important;
}

.comment-list .comment-url,
.comment-list .comment-url:hover,
.comment-list .comment-url:focus {
    transition: all 0.2s ease-in-out;
}

.comment-list .comment-url:hover,
.comment-list .comment-url:focus {
    color: #01F9F9 !important;
    text-decoration: none !important;
}


div#respond {
    margin-right: 3px;
}

#comments .comment, #comments .pingback{
    margin-bottom: 7px !important;
}

p.form-submit {
    margin-right: -2px !important;
    margin-bottom: 7px !important;
}

.custom-submit-button {
    background-color: #0E2D38;
    font-family: "Questrial", Sans-serif;
    font-weight: 600;
    letter-spacing: 0.4px;
    color: #CCCCCC;
    border: 2px solid #0B1924;
    border-radius: 5px;
    width: 100%;
    text-align: center;
    margin-left: -2px;
    margin-right: -2px;
    padding-left: 15px;
    padding-top: 9px;
    height: 46px;
    cursor: pointer;
    transition: all 0.2s ease-in-out;
    text-transform: uppercase;
}

.custom-submit-button:hover,
.custom-submit-button:focus {
    background-color: #163D4C;
    color: #01F9F9;
    border-color: #CCCCCC;
}

textarea#comment:focus,
textarea#comment:active {
    outline: none !important;
    border: 2px solid #0B1924 !important;
    box-shadow: none !important;
}

#comments .children {
    padding-inline-start: 12px;
    border-left: solid 2px #0d2c39;
}

/* Abstand zwischen Kommentaren */
.comment-list > li {
    margin-bottom: 7px !important;
}

/* Autor-Link Farbe + @User Hover */
.comment-list .comment-author-link,
.comment-list .user-mention {
    color: #3E98C2 !important;
    text-decoration: none !important;
    font-weight: bold;
    transition: color 0.2s;
}
.comment-list .comment-author-link:hover,
.comment-list .comment-author-link:focus,
.comment-list .user-mention:hover,
.comment-list .user-mention:focus {
    color: #01F9F9 !important;
    text-decoration: none !important;
}

/* Kein extra Abstand unter Kommentartext */
.comment-list li > div[style*='background-color: #0E2D38'] p {
    margin-bottom: 0 !important;
}

/* Avatar positionieren */
#comments .comment .avatar,
#comments .pingback .avatar {
    position: absolute;
    left: 7px !important;
    top: 9px !important;
}

</style>
<style>
p.MUST-LOG-IN {
    background-color: #0E2D38;
    font-family: "Questrial", Sans-serif;
    font-weight: 600;
    letter-spacing: 0.4px;
    color: #CCCCCC;
    border-style: solid;
    border-width: 2px;
    border-color: #0B1924;
    margin-left: 0px !important;
    border-radius: 5px;
    width: 100%;
    text-align: center;
    height: 46px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-sizing: border-box;
    margin-top: 7px;
    margin-bottom: 7px !important;
    text-transform: uppercase;
    padding-top: 1px;
}

p.MUST-LOG-IN a.mini-action-link {
    color: #CCCCCC !important;
    font-family: inherit;
    font-weight: inherit;
    letter-spacing: inherit;
    text-transform: inherit;
    font-size: inherit;
    background: none;
    border: none;
    text-decoration: underline;
    padding: 0;
    margin: 0;
    transition: color 0.2s;
}
p.MUST-LOG-IN a.mini-action-link:hover,
p.MUST-LOG-IN a.mini-action-link:focus {
    color: #3E98C2 !important;
    text-decoration: underline;
}
</style>
<script>
// Handle Report Comment button click
document.addEventListener('DOMContentLoaded', function() {
    // REPORT COMMENT
    document.querySelectorAll('.report-comment-btn').forEach(function(link) {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            var commentId = this.getAttribute('data-comment-id');
            if (!confirm('Do you really want to report this comment?')) return;
            var el = this;
            el.classList.add('reporting');
            el.textContent = 'Reporting...';
            fetch('<?php echo admin_url('admin-ajax.php'); ?>', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=report_comment&comment_id=' + encodeURIComponent(commentId)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    el.textContent = 'Reported!';
                    el.style.color = '#aaa';
                    el.classList.remove('reporting');
                    el.classList.add('reported');
                    el.removeAttribute('href');
                } else {
                    el.textContent = 'Error';
                    el.classList.remove('reporting');
                    alert(data.data || 'An error occurred.');
                }
            })
            .catch(() => {
                el.textContent = 'Error';
                el.classList.remove('reporting');
                alert('An error occurred.');
            });
        });
    });

    // COPY COMMENT LINK
    document.querySelectorAll('.copy-comment-link').forEach(function(link) {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            var url = this.getAttribute('data-comment-url');
            var el = this;
            if (!url) return;
            // Copy to clipboard
            if (navigator.clipboard) {
                navigator.clipboard.writeText(url).then(function() {
                    el.textContent = 'COPIED!';
                    el.style.color = '#3E98C2';
                    setTimeout(function() {
                        el.textContent = 'COPY LINK';
                        el.style.color = '';
                    }, 1500);
                }, function() {
                    alert('Could not copy link.');
                });
            } else {
                // Fallback for older browsers
                var temp = document.createElement('input');
                temp.value = url;
                document.body.appendChild(temp);
                temp.select();
                try {
                    document.execCommand('copy');
                    el.textContent = 'COPIED!';
                    el.style.color = '#3E98C2';
                    setTimeout(function() {
                        el.textContent = 'COPY LINK';
                        el.style.color = '';
                    }, 1500);
                } catch (err) {
                    alert('Could not copy link.');
                }
                document.body.removeChild(temp);
            }
        });
    });

    // Jiggies Like/Unlike
    function updateJiggiesUI(commentId, count, liked) {
        var countSpan = document.querySelector('.jiggies-count[data-comment-id="' + commentId + '"]');
        var btn = document.querySelector('.jiggies-btn[data-comment-id="' + commentId + '"]');
        if (countSpan) countSpan.textContent = count;
        if (btn) {
            // Passe Text für Einzahl/Mehrzahl an
            var label = (count === 1) ? 'JIGGY EARNED' : 'JIGGIES EARNED';
            // Ersetze alles nach countSpan im Button
            var html = '<span class="jiggies-count" data-comment-id="' + commentId + '">' + count + '</span> ' + label;
            btn.innerHTML = html;
            if (liked) {
                btn.classList.add('jiggy-liked');
                btn.style.color = '#3E98C2';
            } else {
                btn.classList.remove('jiggy-liked');
                btn.style.color = 'rgb(110,110,110)';
            }
        }
    }

    document.querySelectorAll('.jiggies-btn').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            var commentId = this.getAttribute('data-comment-id');
            var el = this;
            el.classList.add('jiggy-loading');
            fetch('<?php echo admin_url('admin-ajax.php'); ?>', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=toggle_jiggy&comment_id=' + encodeURIComponent(commentId)
            })
            .then(response => response.json())
            .then(data => {
                el.classList.remove('jiggy-loading');
                if (data.success) {
                    updateJiggiesUI(commentId, data.data.count, data.data.liked);
                } else {
                    alert(data.data || 'An error occurred.');
                }
            })
            .catch(() => {
                el.classList.remove('jiggy-loading');
                alert('An error occurred.');
            });
        });
    });

    // Initial Jiggies-Count und Status laden
    document.querySelectorAll('.jiggies-count').forEach(function(span) {
        var commentId = span.getAttribute('data-comment-id');
        fetch('<?php echo admin_url('admin-ajax.php'); ?>', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=get_jiggy_status&comment_id=' + encodeURIComponent(commentId)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                updateJiggiesUI(commentId, data.data.count, data.data.liked);
            }
        });
    });
});
</script>

<?php
function link_mentions_and_urls($text) {
    // Verhindere Änderungen innerhalb von HTML-Tags
    return preg_replace_callback('/(<a .*?<\/a>)|([^<]+)/is', function ($matches) {
        // Wenn es sich um einen vorhandenen <a>-Tag handelt, gib ihn unverändert zurück
        if (!empty($matches[1])) {
            return $matches[1];
        }

        // Ansonsten verarbeite den Textteil: zuerst URLs verlinken
        $part = $matches[2];
        $part = preg_replace_callback(
            '/(https?:\/\/[^\s<]+)/i',
            function ($urlMatch) {
                $url = esc_url($urlMatch[1]);
                return '<a href="' . $url . '" target="_blank" rel="noopener noreferrer" class="comment-url" style="color: #3E98C2; font-weight:bold;">' . $url . '</a>';
            },
            $part
        );

        // Danach @Mentions verlinken
        $part = preg_replace_callback('/@([a-zA-Z0-9_-]+)/', function ($mentionMatch) {
            $username = $mentionMatch[1];
            $url = 'https://www.banjocomet.com/user/' . rawurlencode($username) . '/';
            return '<a href="' . esc_url($url) . '" class="user-mention" style="font-weight:bold;">@' . $username . '</a>';
        }, $part);

        return $part;
    }, $text);
}




function custom_comment_id_from_date($comment) {
    // Hole das Datum als Timestamp
    $timestamp = strtotime($comment->comment_date_gmt);
    // Wandle in Base36 um (Zahlen+Kleinbuchstaben)
    $base36 = strtoupper(base_convert($timestamp, 10, 36));
    // Pad auf 8 Stellen, falls nötig
    $base36 = str_pad($base36, 6, '0', STR_PAD_LEFT);
    // Nur die letzten 8 Zeichen nehmen (falls zu lang)
    return substr($base36, -6);
}

function custom_comment_format($comment, $args, $depth) {
    $tag = ($args['style'] === 'div') ? 'div' : 'li';
    $user_login = '';
    if ($comment->user_id) {
        $user_info = get_userdata($comment->user_id);
        if ($user_info) {
            $user_login = $user_info->user_login;
        }
    }
    $profile_url = $user_login ? 'https://www.banjocomet.com/user/' . esc_attr($user_login) . '/' : '';

    // Kommentartext mit @User-Verlinkung filtern
    $comment_text = get_comment_text($comment);
    $comment_text = link_mentions_and_urls($comment_text);
    // Generiere die Kommentar-ID
    $cmt_id = '#' . custom_comment_id_from_date($comment);
    ?>

    <<?php echo $tag; ?> <?php comment_class(); ?> id="comment-<?php comment_ID(); ?>" style="margin: 0px 3px 0px 0px; border: 2px solid #0B1924; border-radius: 5px; overflow: hidden;">

        <!-- Header -->
        <div style="background-color: #09222C; height: 60px; width: 100%; padding: 10px 10px 11px 50px; border-bottom: 2px solid #0B1924; display: flex; align-items: center; gap: 10px; position: relative;">
            <div>
                <?php if ($profile_url): ?>
                    <a href="<?php echo $profile_url; ?>" style="display:inline-block;" title="View profile of <?php echo esc_attr(get_comment_author()); ?>">
                        <?php echo get_avatar($comment, 40); ?>
                    </a>
                <?php else: ?>
                    <?php echo get_avatar($comment, 40); ?>
                <?php endif; ?>
            </div>
            <div style="display: flex; flex-direction: column; line-height: 1.2;">
                <?php if ($profile_url): ?>
                    <a href="<?php echo $profile_url; ?>" class="comment-author-link" title="View profile of <?php echo esc_attr(get_comment_author()); ?>"><?php comment_author(); ?></a>
                <?php else: ?>
                    <span style="color: #3E98C2; font-weight: bold;\"><?php comment_author(); ?></span>
                <?php endif; ?>
                <span style="font-size: 12px; color: #aaa;">
                    <?php
                        $date = get_comment_date('F j, Y');
                        $time = get_comment_time('g:i A');
                        echo 'Posted on ' . $date . ' at ' . $time;
                    ?>
                </span>
            </div>
            <span style="position: absolute; top: 0; right: 0px; background: #0E2D38; color: #cccccc; font-size: 10px; font-family: 'chelsea market', fantasy; font-weight: bold; padding: 2px 10px; border-left: solid 2px; border-bottom: solid 2px; border-color: #0b1924; border-radius: 0px 0px 0px 5px; letter-spacing: 1px; text-transform: uppercase;">
                <?php echo esc_html($cmt_id); ?>
            </span>
        </div>

        <!-- Body -->
        <div style="background-color: #0E2D38; padding: 10px 10px 11px 13px; color: #cccccc;">
            <?php if ($comment->comment_approved == '0') : ?>
                <em>Your comment is awaiting moderation.</em><br/>
            <?php endif; ?>
            <div><?php echo $comment_text; ?></div>
        </div>

        <!-- Footer -->
        <div style="background-color: #09222C; height: 28px; width: 100%; padding: 5px 12px; border-top: 2px solid #0B1924; border-radius: 0px 0px 3px 3px; display: flex; align-items: center;">
            <div style="display: flex; gap: 3px; align-items: center;">
                <a href="#" class="comment-reply-link report-comment-btn mini-action-link" data-comment-id="<?php echo $comment->comment_ID; ?>" style="color:rgb(110,110,110); font-size:11px;">REPORT COMMENT</a>
                <span class="jiggies-separator" style="color:rgb(110,110,110); margin: 0 3px; font-weight: bold; font-size:11px;">-</span>
                <?php
                $jiggies_count = (int) get_comment_meta($comment->comment_ID, '_jiggies_count', true);
                ?>
                <a href="#" class="jiggies-btn mini-action-link" data-comment-id="<?php echo $comment->comment_ID; ?>" style="color:rgb(110,110,110); font-size:11px;">
                    <span class="jiggies-count" data-comment-id="<?php echo $comment->comment_ID; ?>"><?php echo $jiggies_count; ?></span> <?php echo ($jiggies_count === 1) ? 'JIGGY EARNED' : 'JIGGIES EARNED'; ?>
                </a>
                <span style="color:rgb(110,110,110); margin: 0 3px; font-weight: bold; font-size:11px;">-</span>
                <a href="#" class="mini-action-link copy-comment-link" data-comment-id="<?php echo $comment->comment_ID; ?>" data-comment-url="<?php echo esc_url(get_comment_link($comment)); ?>" style="color:rgb(110,110,110); font-size:11px;">COPY LINK</a>
                <?php
                $reply_link = get_comment_reply_link(array_merge($args, array(
                    'depth'     => $depth,
                    'max_depth' => $args['max_depth'],
                    'reply_text' => 'REPLY NOW'
                )), $comment);
                if ($reply_link) {
                    echo '<span style="color:rgb(110,110,110); margin: 0 3px; font-weight: bold; font-size:11px;">-</span>';
                    // Passe Styling für nicht eingeloggte User an
                    if (!is_user_logged_in()) {
                        echo '<a href="https://www.banjocomet.com/login/" class="mini-action-link" style="color:rgb(110,110,110); font-size:11px;">LOG IN TO REPLY</a>';
                    } else {
                        echo $reply_link;
                    }
                }
                ?>
</style>
<style>
.mini-action-link,
.mini-action-link:visited,
.comment-reply-link:not(.report-comment-btn) {
    color: rgb(110,110,110) !important;
    font-size: 11px !important;
    transition: color 0.2s;
    vertical-align: middle;
    padding: 0;
    background: none;
    border: none;
    font-family: inherit;
    font-weight: normal;
    text-transform: none;
}
.mini-action-link:hover,
.mini-action-link:focus,
.comment-reply-link:not(.report-comment-btn):hover,
.comment-reply-link:not(.report-comment-btn):focus {
    color: #3E98C2 !important;
    text-decoration: none !important;
}

.jiggies-btn {
    cursor: pointer;
    user-select: none;
}
.jiggies-btn.jiggy-liked {
    color: #3E98C2 !important;
    font-weight: bold;
}
.jiggies-btn.jiggy-loading {
    opacity: 0.6;
    pointer-events: none;
}
.jiggies-btn:hover,
.jiggies-btn:focus {
    color: #3E98C2 !important;
    text-decoration: none !important;
}
</style>
            </div>
        </div>

    </<?php echo $tag; ?>>

    <?php
}
?>
