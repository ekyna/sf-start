module.exports = function (grunt, options) {
    return {
        web_less: { // For watch:web_less
            files: {
                'src/WebBundle/Resources/public/css/content.css':
                    'src/WebBundle/Resources/public/tmp/css/content.css'
            }
        },
        web_js: { // For watch:web_js
            files: [
                {
                    expand: true,
                    cwd: 'src/WebBundle/Resources/private/js',
                    src: ['*.js'],
                    dest: 'src/WebBundle/Resources/public/js'
                }
            ]
        },
        web_img: {
            files: [
                {
                    expand: true,
                    cwd: 'src/WebBundle/Resources/private/img',
                    src: ['**'],
                    dest: 'src/WebBundle/Resources/public/img'
                }
            ]
        }
    }
};
