module.exports = {
    'build:web': [
        'clean:web_pre',
        'less:web',
        'cssmin:web',
        'uglify:web',
        'clean:web_post'
    ]
};
