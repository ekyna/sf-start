module.exports = function (grunt, options) {
    return {
        web_less: { // For watch:web_less
            files: {
                'src/WebBundle/Resources/public/css/main.css': [
                    'src/WebBundle/Resources/public/tmp/css/main.css',
                    'vendor/ekyna/core-bundle/Resources/public/css/aos.css'
                ]
            }
        }
    }
};
