module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    # ----------------------------------------------------------
    # Build
    # ----------------------------------------------------------
    coffee:
      options:
        bare: yes
      main:
        expand: yes
        cwd: 'src'
        src: '**/*.coffee'
        dest: 'bin'
        ext: '.js'

      option_page:
        expand: yes
        cwd: 'options/coffee'
        src: '**/*.coffee'
        dest: 'options/site/js'
        ext: '.js'

    jade:
      option_page:
        options:
          pretty: yes
        files: [
          expand: yes
          cwd: 'options/jade'
          src: '*.jade'
          dest: 'options/site/html'
          ext: '.html'
        ]

    less:
      main:
        files: [
          expand: yes
          cwd: 'css'
          src: '*.less'
          dest: 'css'
          ext: '.css'
        ]

      option_page:
        files: [
          expand: yes
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
          atBegin: yes

      less_main:
        files: ['css/*.less']
        tasks: ['less:main']
        options:
          atBegin: yes

      option_page_coffee:
        tasks: ['coffee:option_page']
        files: ['options/coffee/*.coffee']
        options:
          atBegin: yes

      option_page_jade:
        files: ['options/jade/*.jade']
        tasks: ['jade']
        options:
          atBegin: yes

      option_page_less:
        files: ['options/less/*.less']
        tasks: ['less:option_page']
        options:
          atBegin: yes

    # ----------------------------------------------------------
    # Clean
    # ----------------------------------------------------------
    g_clean:
      all:
        options:
          force: yes
        src: [
          "bin",
          "css/*.css",
          "options/site",
          "dist"
        ]

    # ----------------------------------------------------------
    # Publish
    # ----------------------------------------------------------
    copy:
      dist:
        files: [
          expand: yes
          dest: 'dist/'
          src: [
            'lib/**',
            'vendor/**',
            'icon/**',
            'css/*.css',
            'options/site/**'
            'manifest.json'
          ]
        ]
      manifest:
        src: 'manifest-dist.json'
        dest: 'dist/manifest.json'

    uglify:
      dist:
        files:
          'dist/js/shared.js': [
            'bin/shared/lodash_mixin.js',
            'bin/shared/util.js'
          ]

          'dist/js/messaging.js': [
            'bin/messaging/message.js',
            'bin/messaging/listener.js'
          ]

          'dist/js/background.js': [
            'bin/background/c_storage.js',
            'bin/background/wintab.js',
            'bin/background/message.js',
            'bin/background/session.js',
            'bin/background/tag.js',
            'bin/background/action.js',
            'bin/background/bookmark.js',
            'bin/background/rank.js',
            'bin/background/log.js',
            'bin/background/main.js',
          ]

          'dist/js/content_script.js': [
            'bin/content_script/hint.js',
            'bin/content_script/action/match_action.js',

            'bin/content_script/action/n_action.js',
            'bin/content_script/action/i_action.js',
            'bin/content_script/action/e_action.js',
            'bin/content_script/action/s_action.js',
            'bin/content_script/action/t_action.js',

            'bin/content_script/handler.js',
           
            'bin/content_script/react/component.js',
            'bin/content_script/react/block.js',
            'bin/content_script/react/lynn.js',

            'bin/content_script/main.js'
          ]

    compress:
      dist:
        options:
          archive: 'lynn.zip'
          pretty: yes
        files: [
          expand: yes
          src: "**/*"
          cwd: "dist"
        ]
    

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-compress')
  grunt.loadNpmTasks('grunt-contrib-uglify')

  # Rename to resolve conflict
  grunt.task.renameTask('watch', 'g_watch')
  grunt.task.renameTask('clean', 'g_clean')

  grunt.registerTask('default', ['coffee', 'jade', 'less'])
  grunt.registerTask('watch', ['g_watch'])
  grunt.registerTask('clean', ['g_clean'])
  grunt.registerTask('pub', ['default', 'uglify', 'copy', 'compress'])

  grunt.event.on 'watch', (action, filepath, target) ->
    grunt.log.writeln(target + ':' + filepath + ' has ' + action)

