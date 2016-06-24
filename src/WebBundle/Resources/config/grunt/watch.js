module.exports = function (grunt, options) {
    return {
        web_less: {
            files: ['src/WebBundle/Resources/private/less/**/*.less'],
            tasks: ['less:web', 'copy:web_less', 'clean:web_post'],
            options: {
                spawn: false
            }
        },
        web_js: {
            files: ['src/WebBundle/Resources/private/js/*.js'],
            tasks: ['copy:web_js'],
            options: {
                spawn: false
            }
        }
    }
};
