module.exports = function(grunt) {

grunt.initConfig({
  copy: {
    highlightjs: {
      files: [
        { src: 'bower_components/highlightjs/highlight.pack.js', dest: 'js/highlight.js' }
      ]
    },
    highlightcss: {
      files: [
        { src: 'bower_components/highlightjs/styles/solarized_dark.css', dest: 'css/highlight.css' }
      ]
    },
    normalizecss: {
      files: [
        { src: 'bower_components/normalize-css/normalize.css', dest: 'css/normalize.css' }
      ]
    },
    fontawesome: {
      files: [
        { src: 'bower_components/font-awesome/css/font-awesome.min.css', dest: 'css/font-awesome.min.css' },
        { src: 'bower_components/font-awesome/fonts/*', dest: 'fonts/', flatten: true, filter: 'isFile', expand: true }
      ]
    }
  },

  exec: {
    build: {
      cmd: 'jekyll build'
    },
    serve: {
      cmd: 'jekyll serve --watch'
    }
  }
});

grunt.loadNpmTasks('grunt-contrib-copy');
grunt.loadNpmTasks('grunt-exec');

grunt.registerTask('default', [ 'copy', 'exec:serve' ]);

};