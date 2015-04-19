# --------------------------------------------------------------
# Coffee
# --------------------------------------------------------------

main_src =
  'js/shared_util.js': [
    'src/shared/util/lodash_mixin.coffee',
    'src/shared/util/util.coffee'
  ]

  'js/shared_messaging.js': [
    'src/shared/messaging/message.coffee',
    'src/shared/messaging/listener.coffee'
  ]

  'js/shared_storage.js': [
    'src/shared/storage/c_storage.coffee'
  ]

  'js/background.js': [
    'src/background/wintab.coffee',
    'src/background/message.coffee',
    'src/background/session.coffee',
    'src/background/tag.coffee',
    'src/background/action.coffee',
    'src/background/bookmark.coffee',
    'src/background/rank.coffee',
    'src/background/log.coffee',
    'src/background/main.coffee',
    'src/background/test.coffee'
  ]

  'js/content_script.js': [
    'src/content_script/hint.coffee',
    'src/content_script/action/match_action.coffee',

    'src/content_script/action/n_action.coffee',
    'src/content_script/action/i_action.coffee',
    'src/content_script/action/e_action.coffee',
    'src/content_script/action/s_action.coffee',
    'src/content_script/action/t_action.coffee',

    'src/content_script/handler.coffee',
   
    'src/content_script/react/element.coffee',
    'src/content_script/react/cheatsheet.coffee',
    'src/content_script/react/component.coffee',
    'src/content_script/react/block.coffee',
    'src/content_script/react/lynn.coffee',

    'src/content_script/main.coffee'
  ]

option_page_src =
  'option_page/site/js/option.js': [
    'option_page/coffee/dashboard.coffee',
    'option_page/coffee/general.coffee',
    'option_page/coffee/tagging.coffee',
    'option_page/coffee/json.coffee',
    'option_page/coffee/main.coffee'
  ]

# --------------------------------------------------------------
# Jade
# --------------------------------------------------------------

jade_option_page =
  'option_page/site/html/option.html': [
    'option_page/jade/main.jade'
  ]

# --------------------------------------------------------------
# Less
# --------------------------------------------------------------

less_main =
  'css/lynn.css': 'less/lynn.less'
  'css/animate.css': 'less/animate.less'

less_option_page =
  'option_page/site/css/option.css': [
    'option_page/less/chrome.less',
    'option_page/less/option_main.less'
  ]

# --------------------------------------------------------------
# Grunt main
# --------------------------------------------------------------

module.exports = (grunt) ->

  grunt.initConfig

    # ----------------------------------------------------------
    # Build
    # ----------------------------------------------------------

    coffee:
      options:
        bare: yes
        join: yes

      # --------------------------------------------------------

      main:
        files: main_src

      option_page:
        files: option_page_src

    jade:
      options:
        pretty: yes

      # --------------------------------------------------------

      option_page:
        files: jade_option_page

    less:
      options:
        compress: yes

      # --------------------------------------------------------

      main:
        files: less_main

      option_page:
        files: less_option_page

    autoprefixer:
      options:
        browsers: ['last 2 versions', 'bb 10']
      animate:
        src: 'css/animate.css'
        dest: 'css/animate.css'

    # ----------------------------------------------------------
    # Watch
    # ----------------------------------------------------------

    g_watch:
      options:
        atBegin: yes

      # --------------------------------------------------------

      coffee_main:
        files: ['src/**/*.coffee']
        tasks: ['coffee:main']

      less_main:
        files: ['less/*.less']
        tasks: ['less:main', 'autoprefixer']

      option_page_coffee:
        files: ['option_page/coffee/*.coffee']
        tasks: ['coffee:option_page']

      option_page_jade:
        files: ['option_page/jade/*.jade']
        tasks: ['jade:option_page']

      option_page_less:
        files: ['option_page/less/*.less']
        tasks: ['less:option_page']

    # ----------------------------------------------------------
    # Clean
    # ----------------------------------------------------------

    g_clean:
      all:
        options:
          force: yes
        src: [
          "js",
          "css",
          "option_page/site",
          "dist",
          "lynn.zip"
        ]

    # ----------------------------------------------------------
    # Dist
    # ----------------------------------------------------------

    copy:
      dist:
        files: [
          expand: yes
          dest: 'dist'
          src: [
            'css/**',
            'lib/**',
            'vendor/**',
            'icon/**',
            'option_page/site/**'
            'manifest.json'
          ]
        ]

    uglify:
      options:
        mangle: yes

      # --------------------------------------------------------

      dist:
        files: [
          expand: yes
          cwd: 'js'
          src: '*.js'
          dest: 'dist/js'
        ]

    compress:
      options:
        archive: 'lynn.zip'
        pretty: yes

      # --------------------------------------------------------

      dist:
        files: [
          expand: yes
          cwd: "dist"
          src: "**/*"
        ]
    
  # ------------------------------------------------------------

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-less')

  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.loadNpmTasks('grunt-contrib-clean')

  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-uglify')

  grunt.loadNpmTasks('grunt-contrib-compress')
  grunt.loadNpmTasks('grunt-autoprefixer')

  # ------------------------------------------------------------
  # Rename to resolve conflict

  grunt.task.renameTask('watch', 'g_watch')
  grunt.task.renameTask('clean', 'g_clean')

  # ------------------------------------------------------------

  grunt.registerTask('default', ['coffee', 'jade', 'less', 'autoprefixer'])

  grunt.registerTask('build', ['default'])
  grunt.registerTask('watch', ['g_watch'])
  grunt.registerTask('clean', ['g_clean'])
  grunt.registerTask('dist', ['default', 'uglify', 'copy', 'compress'])

  # Shorter alias
  grunt.registerTask('b', ['build'])
  grunt.registerTask('w', ['watch'])
  grunt.registerTask('c', ['clean'])
  grunt.registerTask('d', ['dist' ])
  grunt.registerTask('dc', ['dist', 'clean' ])

  grunt.event.on 'watch', (action, filepath, target) ->
    grunt.log.writeln(target + ':' + filepath + ' has ' + action)
