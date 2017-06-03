require([
    'require',
    'jquery',
    'ekyna-cms/user',
    'ekyna-user/user-widget',
    'ekyna-media-player',
    'ekyna-dispatcher',
    'aos',
    'ekyna-social-buttons/share',
    'bootstrap',
    'bootstrap/hover-dropdown'
],
function(require, $, User, UserWidget, MediaPlayer, Dispatcher, AOS) {

    User.init();

    UserWidget.initialize().enable();

    MediaPlayer.init();

    /*Dispatcher.on('ekyna_user.user_status', function(e) {
        console.log('User status : ' + e.authenticated);
    });*/

    AOS.init({
        offset: 200
    });

    // Forms
    var $forms = $('.form-body');
    if ($forms.size() > 0) {
        require(['ekyna-form'], function(Form) {
            $forms.each(function(i, f) {
                var form = Form.create(f);
                form.init();
            });
        });
    }

    // Sticky footer
    function stickyFooter() {
        $('body').css({paddingBottom: $('#footer').outerHeight()});
    }
    var resizeTimeout = null;
    $(window).on('resize', function() {
        if (resizeTimeout) {
            clearTimeout(resizeTimeout);
        }
        resizeTimeout = setTimeout(stickyFooter, 200);
    });

    $(document).ready(function () {
        stickyFooter();
    });
});
