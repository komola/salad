path = require "path"

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    uglify:
      options:
        banner: '/*! <%= pkg.name %> v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %> */\n'
        report: 'min'
        # preserveComments: (node, comment) ->
        #   comment.type is "comment2" and comment.value.indexOf("license") isnt -1

    concat:
      client:
        options:
          separator: ";"
          stripBanners:
            line: true
            block: false
          # process: true

        files:
          "build/salad.js": [
            "lib/{shared, client}/**/*.js"
          ]

    coffee:
      client:
        options:
          sourceMap: false
        files: [
          expand: true
          src: ["src/**/*.coffee"]
          dest: "lib"
          rename: (folder, name) ->
            name = name.replace(/(src)\//, "")

            [folder, name].join path.sep
          ext: ".js"
        ]

  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"

  grunt.registerTask "compile", ["coffee", "concat"]
  grunt.registerTask "default", ["compile"]
