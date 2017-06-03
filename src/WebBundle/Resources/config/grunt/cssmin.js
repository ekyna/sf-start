module.exports = function (grunt, options) {
    return {
        web: {
            files: {
                'src/WebBundle/Resources/public/css/main.css': [
                    'src/WebBundle/Resources/public/tmp/css/main.css',
                    'vendor/ekyna/core-bundle/Resources/public/css/aos.css'
                ],
                'src/WebBundle/Resources/public/css/content.css': [
                    'src/WebBundle/Resources/public/tmp/css/content.css'
                ]
            }
        }
    }
};
