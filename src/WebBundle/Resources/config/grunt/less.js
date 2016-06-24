module.exports = function (grunt, options) {
    // @see https://github.com/gruntjs/grunt-contrib-less
    return {
        web: {
            files: {
                'src/WebBundle/Resources/public/tmp/css/main.css':
                    'src/WebBundle/Resources/private/less/main.less',
                'src/WebBundle/Resources/public/tmp/css/content.css':
                    'src/WebBundle/Resources/private/less/content.less'
            }
        }
    }
};
