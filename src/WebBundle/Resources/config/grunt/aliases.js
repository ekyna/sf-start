module.exports = {
    'build:web': [
        'clean:web_pre',
        'less:web',
        'cssmin:web',
        'uglify:web',
        'copy:web_img',
        'clean:web_post'
    ]
};
