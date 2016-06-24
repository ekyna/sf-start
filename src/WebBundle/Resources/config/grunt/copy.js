module.exports = function (grunt, options) {
    return {
        web_less: { // For watch:app_less
            files: [
                {
                    expand: true,
                    cwd: 'src/WebBundle/Resources/public/tmp/css',
                    src: ['**'],
                    dest: 'src/WebBundle/Resources/public/css'
                }
            ]
        },
        web_js: { // For watch:app_js
            files: [
                {
                    expand: true,
                    cwd: 'src/WebBundle/Resources/private/js',
                    src: ['*.js'],
                    dest: 'src/WebBundle/Resources/public/js'
                }
            ]
        }
    }
};
