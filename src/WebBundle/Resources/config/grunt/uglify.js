module.exports = function (grunt, options) {
    return {
        web: {
            files: {
                'src/WebBundle/Resources/public/js/main.js': [
                    'src/WebBundle/Resources/private/js/main.js'
                ]
            }
        }
    }
};
