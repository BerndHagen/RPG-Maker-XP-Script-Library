add_action('wp_ajax_get_jiggy_status', 'handle_get_jiggy_status_ajax');
add_action('wp_ajax_nopriv_get_jiggy_status', 'handle_get_jiggy_status_ajax');
function handle_get_jiggy_status_ajax() {
    if (!isset($_POST['comment_id']) || !is_numeric($_POST['comment_id'])) {
        wp_send_json_error('Invalid comment ID.');
    }
    $comment_id = intval($_POST['comment_id']);
    $jiggies_users = get_comment_meta($comment_id, '_jiggies_users', true);
    if (!is_array($jiggies_users)) {
        $jiggies_users = array();
    }
    $count = count($jiggies_users);
    $liked = false;
    if (is_user_logged_in()) {
        $user_id = get_current_user_id();
        $liked = in_array($user_id, $jiggies_users);
    }
    wp_send_json_success(array(
        'count' => $count,
        'liked' => $liked
    ));
}
/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* AJAX HANDLER: JIGGIES LIKE SYSTEM */
/*------------------------------------------------------------------------------------------------------------------------------------------*/

add_action('wp_ajax_toggle_jiggy', 'handle_toggle_jiggy_ajax');
add_action('wp_ajax_nopriv_toggle_jiggy', 'handle_toggle_jiggy_ajax');
function handle_toggle_jiggy_ajax() {
    if (!isset($_POST['comment_id']) || !is_numeric($_POST['comment_id'])) {
        wp_send_json_error('Invalid comment ID.');
    }
    $comment_id = intval($_POST['comment_id']);
    $comment = get_comment($comment_id);
    if (!$comment) {
        wp_send_json_error('Comment not found.');
    }

    if (!is_user_logged_in()) {
        wp_send_json_error('You must be logged in.');
    }
    $user_id = get_current_user_id();

    $jiggies_users = get_comment_meta($comment_id, '_jiggies_users', true);
    if (!is_array($jiggies_users)) {
        $jiggies_users = array();
    }

    $liked = false;
    if (in_array($user_id, $jiggies_users)) {
        // Unlike
        $jiggies_users = array_diff($jiggies_users, array($user_id));
    } else {
        // Like
        $jiggies_users[] = $user_id;
        $liked = true;
    }
    // Reindex array
    $jiggies_users = array_values($jiggies_users);
    update_comment_meta($comment_id, '_jiggies_users', $jiggies_users);
    update_comment_meta($comment_id, '_jiggies_count', count($jiggies_users));

    wp_send_json_success(array(
        'count' => count($jiggies_users),
        'liked' => $liked
    ));
}
/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* AJAX HANDLER: REPORT COMMENT */
/*------------------------------------------------------------------------------------------------------------------------------------------*/

add_action('wp_ajax_report_comment', 'handle_report_comment_ajax');
add_action('wp_ajax_nopriv_report_comment', 'handle_report_comment_ajax');
function handle_report_comment_ajax() {
    if (!isset($_POST['comment_id']) || !is_numeric($_POST['comment_id'])) {
        wp_send_json_error('Invalid comment ID.');
    }
    $comment_id = intval($_POST['comment_id']);
    $comment = get_comment($comment_id);
    if (!$comment) {
        wp_send_json_error('Comment not found.');
    }

    $post = get_post($comment->comment_post_ID);
    $author = get_userdata($comment->user_id);
    $author_name = $author ? $author->user_login : $comment->comment_author;
    $author_email = $author ? $author->user_email : $comment->comment_author_email;

    $subject = '[REPORT] Comment Alert';
    $message = "A comment has been reported.\n\n" .
        "Comment ID: $comment_id\n" .
        "Post: " . get_the_title($comment->comment_post_ID) . " (ID: {$comment->comment_post_ID})\n" .
        "Author: $author_name ($author_email)\n" .
        "Date: $comment->comment_date\n" .
        "Content:\n$comment->comment_content\n\n" .
        "View: " . get_permalink($comment->comment_post_ID) . "#comment-$comment_id\n";

    $sent = wp_mail('support@banjocomet.com', $subject, $message);
    if ($sent) {
        wp_send_json_success();
    } else {
        wp_send_json_error('Failed to send report email.');
    }
}
<?php
/**
 * Theme functions and definitions
 *
 * @package HelloElementorChild
 */

/**
 * Load child theme css and optional scripts
 *
 * @return void
 */
function hello_elementor_child_enqueue_scripts() {
    wp_enqueue_style(
        'hello-elementor-child-style',
        get_stylesheet_directory_uri() . '/style.css',
        [
            'hello-elementor-theme-style',
        ],
        '1.0.0'
    );
}
add_action( 'wp_enqueue_scripts', 'hello_elementor_child_enqueue_scripts', 20 );
add_filter( 'avatar_defaults', 'wpb_new_gravatar' );

function wpb_new_gravatar ($avatar_defaults) {
$myavatar = 'https://www.banjocomet.com/wp-content/uploads/2023/02/128px_GuestAvatar.png';
$avatar_defaults[$myavatar] = "Jiggy Icon";
return $avatar_defaults;
}

function load_comment_reply_script() {
    if (is_singular() && comments_open() && get_option('thread_comments')) {
        wp_enqueue_script('comment-reply');
    }
}
add_action('wp_enqueue_scripts', 'load_comment_reply_script');


/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* IMAGES WITH BIGGER SIZES
/*------------------------------------------------------------------------------------------------------------------------------------------*/

function td_big_image_size_threshold( $threshold, $imagesize, $file, $attachment_id ) {
    return 5300;
}
add_filter( 'big_image_size_threshold', 'td_big_image_size_threshold', 10, 4 );

/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* SETS AMOUNT OF SEARCH RESULTS
/*------------------------------------------------------------------------------------------------------------------------------------------*/

function control_search_results( $query ) {
    if ( is_search() && $query->is_main_query() ) {
        // Set the number of results per page to 40
        $query->set( 'posts_per_page', 40 );
        
        // After the query runs, adjust the results if necessary
        add_action('the_posts', function($posts, $query) {
            // Check if the current number of posts is odd
            if ( count( $posts ) % 2 != 0 ) {
                // Create a blank entry (it can be a WP_Post object with empty content or metadata)
                $blank_post = (object) array(
                    'ID' => 0,
                    'post_title' => '',
                    'post_content' => '',
                    'post_excerpt' => '',
                    'post_type' => 'post',
                    'post_status' => 'publish',
                );
                
                // Add the blank post to the end of the array
                $posts[] = $blank_post;
            }
            return $posts;
        }, 10, 2);
    }
}

/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* COMMENT SYSTEM FOR PROFILE
/*------------------------------------------------------------------------------------------------------------------------------------------*/
function render_user_comments_with_gamification($atts) {
    global $wp;

    $current_url = home_url(add_query_arg(array(), $wp->request));
    $path_segments = explode('/', trim(parse_url($current_url, PHP_URL_PATH), '/'));
    $username = end($path_segments);

    $viewed_user = get_user_by('login', $username);

    if (!$viewed_user) {
        return '<div class="comments-status-message">User not found.</div>';
    }

    // Get all approved comments made by the user
    $comments = get_comments(array(
        'user_id' => $viewed_user->ID,
        'status' => 'approve',
    ));

    // Group comments by post ID
    $comments_by_post = [];
    foreach ($comments as $comment) {
        if (!isset($comments_by_post[$comment->comment_post_ID])) {
            $comments_by_post[$comment->comment_post_ID] = [];
        }
        $comments_by_post[$comment->comment_post_ID][] = $comment;
    }

    // Fetch all published posts (not just those authored by the user)
    $all_posts = get_posts(array(
        'posts_per_page' => -1,
        'post_status' => 'publish',
    ));

    $output = '';

    if (empty($all_posts)) {
        $output .= '<div class="comments-status-message">No posts available.</div>';
    } else {
        // Start the comment grid layout
        $output .= '<div class="user-comments-grid" style="width: 646px; margin-top: 4px; display: flex; flex-wrap: wrap; gap: 7px;">';

        // Track the number of boxes to check for odd numbers later
        $box_count = 0;

        // Display each post
        foreach ($all_posts as $post) {
            $post_id = $post->ID;
            $post_permalink = get_permalink($post_id);

            // Get the comment count for this post from the viewed user
            $comment_count = isset($comments_by_post[$post_id]) ? count($comments_by_post[$post_id]) : 0;

            // Add the image (gamification badge) in a separate purple container if 3 or more comments exist
            $icon_image = get_gamification_icon($comment_count);
            if ($icon_image) {
                $output .= '<div class="comment-icon-container" style="background-color: #0E2D38; padding: 5px; border-radius: 5px; width: 64px; height: 64px; border-color: #0B1924; border-style: solid; border-width: 2px; display: flex; justify-content: center; align-items: center;">';
                $output .= '<img src="' . esc_url($icon_image) . '" alt="User Badge" style="width: 50px; height: 50px; border-radius: 5px; border-color: #0B1924; border-style: solid; border-width: 2px;">';
                $output .= '</div>';
            }

            // Create a post comment box separately from the image
            $output .= '<div class="user-comment" style="width: 245px;  height: 64px;  padding: 10px; border: 2px solid #0B1924; border-radius: 5px; display: flex; flex-direction: column; justify-content: center; margin: 0 !important">';
            $output .= '<div class="comment-post-title" style="font-weight: bold; margin-bottom: 5px;"><a href="' . esc_url($post_permalink) . '">' . get_the_title($post_id) . '</a></div>';
            $output .= '<div class="comment-count">Number of comments: ' . esc_html($comment_count) . '</div>';
            $output .= '</div>';

            $box_count++;
        }

        // If the total number of boxes is odd, add a single placeholder to make it even
        if ($box_count % 2 != 0) {
            $output .= '<div class="user-comment placeholder-box" style="width: 316px;  height: 64px; padding: 10px; border: 2px solid #0B1924; border-radius: 5px;">';
            $output .= '<div class="placeholder-content" style="height: 42px; display: flex; align-items: center; justify-content: center;">[Empty]</div>';
            $output .= '</div>';
        }

        // Close the comment grid
        $output .= '</div>';
    }

    return $output;
}

// New function to determine which icon to display based on the number of comments
function get_gamification_icon($comment_count) {
    $default_icon = 'https://www.banjocomet.com/wp-content/uploads/2024/09/64px_JiggyLocked_Icon.png';
    $special_icon = 'https://www.banjocomet.com/wp-content/uploads/2023/02/64px_JiggyChallenge_Icon.png';

    // Return the special icon if the user has made 3 or more comments on the post
    if ($comment_count >= 3) {
        return $special_icon;
    }

    return $default_icon;
}

add_shortcode('user_comments', 'render_user_comments_with_gamification');




/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* USER LEVEL SYSTEM
/*------------------------------------------------------------------------------------------------------------------------------------------*/

function render_user_gamification_level($atts) {
    global $wp;

    $current_url = home_url(add_query_arg(array(), $wp->request));
    $path_segments = explode('/', trim(parse_url($current_url, PHP_URL_PATH), '/'));
    $username = end($path_segments);

    $viewed_user = get_user_by('login', $username);

    if (!$viewed_user) {
        return '<div class="gamification-status-message">User not found.</div>';
    }

    // Get all approved comments made by the user
    $comments = get_comments(array(
        'user_id' => $viewed_user->ID,
        'status' => 'approve'
    ));

    // Create an array to count comments for each post
    $comments_by_post = [];

    // Loop through the comments and count comments for each post
    foreach ($comments as $comment) {
        if (!isset($comments_by_post[$comment->comment_post_ID])) {
            $comments_by_post[$comment->comment_post_ID] = 0;
        }
        $comments_by_post[$comment->comment_post_ID]++;
    }

    // Count posts where the user has made 3 or more comments
    $qualified_posts = 0;
    foreach ($comments_by_post as $post_id => $comment_count) {
        if ($comment_count >= 3) {
            $qualified_posts++;
        }
    }

    // Calculate the level based on the number of posts with 3 or more comments
    $level = $qualified_posts;

    // Generate the HTML output
    $output = '<div class="gamification-scores">';

    // Display the level with a custom CSS class for styling
    $output .= '<div class="gamification-level">';
    $output .= '<span class="level-title">Jiggies</span> <span class="level-number">' . esc_html($level) . '</span>';
    $output .= '</div>';

    $output .= '</div>';

    return $output;
}

add_shortcode('user_gamification', 'render_user_gamification_level');


/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* CUSTOM MEMBER LOGIN BOX
/*------------------------------------------------------------------------------------------------------------------------------------------*/

function custom_member_login_shortcode() {
    $default_avatar_url = 'https://www.banjocomet.com/wp-content/uploads/2023/02/128px_GuestAvatar.png';
    $current_user = wp_get_current_user();

    if (is_user_logged_in()) {
        $avatar = get_avatar($current_user->ID, 32, '', '', array('url' => $default_avatar_url));
        $account_url = home_url('/user/') . $current_user->user_login . '/';
        $output = '<a href="' . esc_url($account_url) . '"><div class="avatar-container">' . $avatar . '</div>Your Profile</a>';
    } else {
        // No avatar displayed if the user is not logged in, and custom margins applied to the link text
        $output = '<a href="' . esc_url(home_url('/login/')) . '" style="margin-left: 2px; margin-top: 4px; display: inline-block;">Login/Register</a>';
    }

    return $output;
}

add_shortcode('custom_member_login', 'custom_member_login_shortcode');



/*------------------------------------------------------------------------------------------------------------------------------------------*/
/* CUSTOM PASSWORD RESET FORM
/*------------------------------------------------------------------------------------------------------------------------------------------*/

function custom_password_reset_form() {
    $is_logged_in = is_user_logged_in();
    $form_submitted = isset($_POST['reset_password']);
    $is_reset_action = isset($_GET['action']) && $_GET['action'] == 'rp';
    $user = false;
    $password_reset_success = isset($_SESSION['password_reset_success']) ? $_SESSION['password_reset_success'] : '';

    unset($_SESSION['password_reset_success']);

    if ($is_logged_in) {
        $current_user = wp_get_current_user();
        $username = $current_user->user_login;
        $back_to_login_url = esc_url(home_url("/user/$username/"));
    } else {
        $back_to_login_url = esc_url(home_url('/login/'));
    }

    if ($is_reset_action && isset($_GET['key']) && isset($_GET['login'])) {
        $user = check_password_reset_key($_GET['key'], $_GET['login']);
    }

    if ($is_reset_action && $user && !is_wp_error($user)) {
        ?>
        <form method="post">
            <img src="https://www.banjocomet.com/wp-content/uploads/2024/01/64px_PasswordIcon.png" alt="Password Icon">
            <input type="hidden" name="rp_key" value="<?php echo esc_attr($_GET['key']); ?>">
            <input type="hidden" name="rp_login" value="<?php echo esc_attr($_GET['login']); ?>">
            <input type="password" name="new_password" placeholder="New Password" class="um-field-block">
            <div class="buttons-container">
                <input type="submit" name="submit_new_password" value="Change Password" class="form-button">
                <a href="<?php echo $back_to_login_url; ?>" class="form-button">
                        <button type="button">
                            <?php echo $is_logged_in ? 'Back to Profile' : 'Back to Login'; ?>
                        </button>
                    </a>
            </div>
        </form>
        <?php
    } else {
        ?>
        <form id="custom-password-reset-form" method="post">
            <img src="https://www.banjocomet.com/wp-content/uploads/2024/01/64px_MailIcon.png" alt="Profile Icon">
            <input type="text" name="user_email" placeholder="Email Address" class="um-field-block">
            <span id="email-error-message" style="color:red; display:none;">Please enter a valid email address</span>
            <div class="buttons-container">
                <input type="submit" name="reset_password" value="Reset Password" class="form-button">
                <a href="<?php echo $back_to_login_url; ?>" class="form-button">
                        <button type="button">
                            <?php echo $is_logged_in ? 'Back to Profile' : 'Back to Login'; ?>
                        </button>
                    </a>
            </div>
        </form>
        <script>
            document.getElementById('custom-password-reset-form').addEventListener('submit', function(event) {
                var emailInput = document.getElementsByName('user_email')[0];
                var errorMessage = document.getElementById('email-error-message');
                var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

                if (!emailPattern.test(emailInput.value)) {
                    errorMessage.style.display = 'block';
                    event.preventDefault();
                } else {
                    errorMessage.style.display = 'none';
                }
            });
        </script>
        <?php
    }

    if ($form_submitted) {
        echo '<p class="info-message">Check your email for instructions to set a new password. If it\'s not in your inbox, please check your spam or junk folder. Follow the link to create a new password and regain access.</p>';
    }
    
    if (!empty($password_reset_success)) {
        echo '<p class="success-message">' . esc_html($password_reset_success) . '</p>';
        unset($_SESSION['password_reset_success']); // Clear the message after displaying it
    }


    if (isset($_SESSION['password_reset_error']) && !empty($_SESSION['password_reset_error'])) {
        echo '<p class="error-message">' . esc_html($_SESSION['password_reset_error']) . '</p>';
        unset($_SESSION['password_reset_error']); // Clear the message after displaying it
    }
}

add_shortcode('custom_password_reset_form', 'custom_password_reset_form');

// Handle Custom Password Reset Form Submission
function handle_custom_password_reset() {
    if (isset($_POST['reset_password']) && isset($_POST['user_email'])) {
        $user_email = sanitize_email($_POST['user_email']);
        $user = get_user_by('email', $user_email);

        if ($user) {
            $reset_key = get_password_reset_key($user);
            $reset_url = home_url('/restore-password/?action=rp&key=' . $reset_key . '&login=' . rawurlencode($user->user_login));

            // Set the title of the email
            $blogname = wp_specialchars_decode(get_option('blogname'), ENT_QUOTES);
            $title = sprintf( __('Password Reset Request'), $blogname );

            $message = 'You requested a password reset. To reset your password, click the following link: ' . $reset_url;

            wp_mail($user_email, $title, $message);
        }
    }
}

add_action('init', 'handle_custom_password_reset');

// Process New Password Submission
// Process New Password Submission
function process_new_password() {
    if (isset($_POST['submit_new_password'])) {
        $rp_key = $_POST['rp_key'];
        $rp_login = $_POST['rp_login'];
        $new_password = $_POST['new_password'];

        // Check if the new password meets the required criteria
        if (strlen($new_password) < 8) {
            // Set an error message
            $_SESSION['password_reset_error'] = 'Password must be at least 8 characters.';
            return; // Exit the function
        }

        $user = check_password_reset_key($rp_key, $rp_login);
        if (!is_wp_error($user)) {
            reset_password($user, $new_password);
            // Set a success message
            $_SESSION['password_reset_success'] = 'Your password has been successfully changed.';
        } else {
            // Handle other error cases
            $_SESSION['password_reset_error'] = 'There was an error resetting your password.';
        }
    }
}

add_action('init', 'process_new_password');

// Function to change email address
function wpb_sender_email( $original_email_address ) {
    return 'noreply@banjocomet.com';
}

// Function to change sender name
function wpb_sender_name( $original_email_from ) {
    return 'Banjocomet.com';
}

// Hooking up our functions to WordPress filters 
add_filter( 'wp_mail_from', 'wpb_sender_email' );
add_filter( 'wp_mail_from_name', 'wpb_sender_name' );