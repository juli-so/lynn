module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    # ----------------------------------------------------------
    # Build
    # ----------------------------------------------------------
    coffee:
      options:
        bare: true
      main:
        expand: true
        cwd: 'src'
        src: '**/*.coffee'
        dest: 'bin'
        ext: '.js'

      option_page:
        expand: true
        cwd: 'options/coffee'
        src: '**/*.coffee'
        dest: 'options/site/js'
        ext: '.js'

    jade:
      option_page:
        options:
          pretty: yes
        files: [
          expand: true
          cwd: 'options/jade'
          src: '*.jade'
          dest: 'options/site/html'
          ext: '.html'
        ]

    less:
      main:
        files: [
          expand: true
          cwd: 'css'
          src: '*.less'
          dest: 'css'
          ext: '.css'
        ]

      option_page:
        files: [
          expand: true
          cwd: 'options/less'
          src: '*.less'
          dest: 'options/site/css'
          ext: '.css'
        ]

    # ----------------------------------------------------------
    # Watch
    # ----------------------------------------------------------
    g_watch:
      coffee_main:
        files: ['src/**/*.coffee']
        tasks: ['coffee:main']
        options:
          atBegin: true

      less_main:
        files: ['css/style.less']
        tasks: ['less:main']
        options:
          atBegin: true

      option_page_coffee:
        tasks: ['coffee:option_page']
        files: ['options/coffee/*.coffee']
        options:
          atBegin: true

      option_page_jade:
        files: ['options/jade/*.jade']
        tasks: ['jade']
        options:
          atBegin: true

      option_page_less:
        files: ['options/less/*.less']
        tasks: ['less:option_page']
        options:
          atBegin: true

    # ----------------------------------------------------------
    # Clean
    # ----------------------------------------------------------
    g_clean:
      all:
        options:
          force: yes
        src: [
          "bin/*",
          "css/*.css",
          "options/site/*"
        ]
  
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')

  # Rename to resolve conflict
  grunt.task.renameTask('watch', 'g_watch')
  grunt.task.renameTask('clean', 'g_clean')

  grunt.registerTask('default', ['coffee', 'jade', 'less'])
  grunt.registerTask('watch', ['g_watch'])
  grunt.registerTask('clean', ['g_clean'])

  grunt.event.on 'watch', (action, filepath, target) ->
    grunt.log.writeln(target + ':' + filepath + ' has ' + action)

