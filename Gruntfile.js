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
        { src: 'bower_components/highlightjs/styles/default.css', dest: 'css/highlight.css' }
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