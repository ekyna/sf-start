module.exports = function(grunt) {

    var path = require('path'),
        globule = require('globule');

    // Grunt config directories
    var directories = globule.find('app/grunt/', 'src/**/grunt/');
    directories.forEach(function(value, key, array) {
        "use strict";
        array[key] = path.join(process.cwd(), value);
    });

    require('load-grunt-config')(grunt, {

        // path to task.js files, defaults to grunt dir
        configPath: directories, /*[
            path.join(process.cwd(), 'grunt'),
            path.join(process.cwd(), 'src/Cms/grunt'),
            path.join(process.cwd(), 'src/Test/grunt')
        ],*/

        // auto grunt.initConfig
        init: true,

        // data passed into config.  Can use with <%= test %>
        /*data: {
            test: false
        },*/

        // use different function to merge config files
        mergeFunction: require('recursive-merge'),

        // can optionally pass options to load-grunt-tasks.
        // If you set to false, it will disable auto loading tasks.
        loadGruntTasks: {
            //pattern: 'grunt-*',
            //config: require('./package.json'),
            //scope: 'devDependencies'
        },

        //can post process config object before it gets passed to grunt
        postProcess: function(config) {},

        //allows to manipulate the config object before it gets merged with the data object
        preMerge: function(config, data) {}
    });
};
