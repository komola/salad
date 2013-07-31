global.Sequelize = require("sequelize")
global.async = require "async"
winston = require "winston"
findit = require "findit"
fs = require "fs"
# require "longjohn"

class Salad.Bootstrap extends Salad.Base
  @extend require "./mixins/Singleton"
  @mixin require "./mixins/metadata"
  @mixin require "./mixins/triggers"

  app: null

  options:
    routePath: "app/config/server/routes"
    controllerPath: "app/controllers/server"
    modelPath: "app/models/server"
    configPath: "app/config/server/config"
    templatePath: "app/templates"
    publicPath: "public"
    port: 80
    env: "production"

  init: (options, callback) ->
    @constructor.after "init", @initConfig
    @constructor.after "init", @initLogger
    @constructor.after "init", @initControllers
    @constructor.after "init", @initRoutes
    @constructor.after "init", @initHelpers
    @constructor.after "init", @initDatabase
    @constructor.after "init", @initModels
    @constructor.after "init", @initTemplates
    @constructor.after "init", @initAssets
    @constructor.after "init", @initExpress

    async.series [
      (cb) => @runTriggers "before:init", cb
      (cb) =>
        @options.port = options.port || 80
        @options.env = Salad.env = options.env || "production"

        cb()

      (cb) => @runTriggers "after:init", cb
    ], (err) =>
      callback()

  run: (options) ->
    @init options, =>
      @start options.cb

  @run: (options) ->
    options or= {}

    Salad.Bootstrap.instance().run options

  initConfig: (cb) ->
    # Salad.Config = require("require-all")
    #   dirname: "#{Salad.root}/#{@options.configPath}"

    # TODO: Allow more than one file and external configuration, i.e.
    # in the /etc folder
    Salad.Config = require "#{Salad.root}/#{@options.configPath}"

    cb()

  initLogger: (cb) ->
    @metadata().logger = new winston.Logger
    @metadata().logger.setLevels winston.config.syslog.levels

    @metadata().logger.add winston.transports.Console,
      handleExceptions: true
      prettyPrint: true
      colorize: true
      timestamp: true

    App.Logger = {}

    @metadata().logger.extend App.Logger

    App.Logger.log = ->
      @metadata().logger.info.apply @, arguments

    if Salad.env isnt "testing"
      console.log = App.Logger.log
      console.error = App.Logger.error

    cb()

  initRoutes: (cb) ->
    require "#{Salad.root}/#{@options.routePath}"

    cb()

  initControllers: (cb) ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.controllerPath}"

    cb()

  initHelpers: (cb) ->
    cb()

  initModels: (cb) ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.modelPath}"

    cb()

  initTemplates: (cb) ->
    # TODO Implement possibility for development environment to auto-load changes using gaze

    # find all templates and save their content in a hash
    files = []
    @metadata().templates = {}

    dirname = "#{Salad.root}/#{@options.templatePath}"

    finder = findit dirname

    # we received a file
    finder.on "file", (file, stat) =>
      files.push file

    # we received all files.
    finder.on "end", =>
      async.eachSeries files,
        readFile = (file, done) =>
          fs.readFile file, (err, content) =>
            index = file.replace(dirname, "").replace(/\/(server|shared)\//, "")
            @metadata().templates[index] = content.toString()

            done()

        # we are done!
        finished = (err) =>
          cb()

  initAssets: (cb) ->
    files = []
    folders = []
    @metadata().assets = []

    for folder in ["controllers", "models", "config", "templates"]
      folders.push "#{Salad.root}/app/#{folder}/client"
      folders.push "#{Salad.root}/app/#{folder}/shared"

    async.eachSeries folders,
      findFilesInFolder = (dirname, done) =>
        # don't parse when the folder does not exist
        unless fs.existsSync dirname
          return done()

        finder = findit dirname

        # we received a file
        finder.on "file", (file, stat) =>
          files.push file

        # we received all files.
        finder.on "end", =>
          done()

      done = (err) =>
        @metadata().assets = files
        cb()

  initDatabase: (cb) ->
    dbConfig = Salad.Config.database[Salad.env]

    App.sequelize = new Sequelize dbConfig.database, dbConfig.username, dbConfig.password,
      dialect: "postgres"
      host: dbConfig.host
      port: dbConfig.port
      logging: if Salad.env is "development" then console.log else false
      omitNull: true

    cb()

  initExpress: (cb) ->
    express = require "express"
    @metadata().app = express()

    @metadata().app.use express.bodyParser()
    @metadata().app.use express.methodOverride()
    @metadata().app.use express.static("#{Salad.root}/public")

    router = new Salad.Router
    @metadata().app.all "*", router.dispatch

    cb()

  start: (callback) =>

    async.series [
      (cb) => @runTriggers "before:start", cb
      (cb) =>
        @metadata().expressServer = @metadata().app.listen @options.port
        cb()

      (cb) => @runTriggers "after:start", cb
    ], (err) =>
      callback.apply @ if callback

  @destroy: (callback) ->
    @instance().destroy callback

  destroy: (callback) ->
    async.series [
      (cb) => @runTriggers "before:destroy", cb
      (cb) =>
        @metadata().expressServer.close cb
        cb()

      (cb) => @runTriggers "after:destroy", cb
    ], (err) =>
      callback.apply @ if callback
