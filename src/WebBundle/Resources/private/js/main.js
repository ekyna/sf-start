require([
    'require',
    'jquery',
    'ekyna-cms/cms',
    'ekyna-user/user-widget',
    'ekyna-media-player',
    'ekyna-dispatcher',
    'aos',
    //'ekyna-commerce/cart-widget',
    'ekyna-social-buttons/share',
    'bootstrap',
    'bootstrap/hover-dropdown'
],
function(require, $, Cms, UserWidget, MediaPlayer, Dispatcher, AOS/*, CartWidget*/) {

    var debug = $('html').data('debug');

    MediaPlayer.init();

    Cms.init();

    UserWidget.initialize({debug: debug}).enable();

    //CartWidget.initialize().enable();

    /*Dispatcher.on('ekyna_user.user_status', function(e) {
        console.log('User status : ' + e.authenticated);
    });*/

    AOS.init({
        offset: 200
    });

    // Forms
    var $forms = $('form');
    if ($forms.size() > 0) {
        require(['ekyna-form'], function(Form) {
            $forms.each(function(i, f) {
                var form = Form.create(f);
                form.init();
            });
        });
    }

    // Toggle details
    $(document).on('click', 'a[data-toggle-details]', function(e) {
        e.preventDefault();

        var $this = $(this), $target = $('#' + $this.data('toggle-details'));

        if (1 === $target.size()) {
            if ($target.is(':visible')) {
                $target.hide();
            } else {
                $target.show();
            }
        }

        return false;
    });

    // Sticky footer
    /*function stickyFooter() {
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
    });*/
});
