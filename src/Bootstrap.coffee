global.Sequelize = require("sequelize")
global.async = require "async"
winston = require "winston"
findit = require "findit2"
fs = require "fs"
gaze = require "gaze"
path = require "path"
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
    templatePath: ["app", "templates"].join(path.sep)
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
    @constructor.after "init", @initExpress

    async.series [
      (cb) => @runTriggers "before:init", cb
      (cb) =>
        @options.port = options.port || 80
        @options.env = Salad.env = options.env || "production"

        cb()

      (cb) => @runTriggers "after:init", cb
    ], (err) =>
      callback() if callback

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

    App.Logger.log = =>
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
    # find all templates and save their content in a hash
    files = []
    @metadata().templates = {}

    dirname = [Salad.root, @options.templatePath].join(path.sep)

    unless fs.existsSync dirname
      throw new Error "Templates folder does not exist! #{dirname}"

    loadTemplateFile = (file, cb) =>
      fs.readFile file, (err, content) =>
        file = path.normalize(file)
        index = file
          .replace(path.normalize(dirname), "")
          .replace(/\\/g, "/")
          .replace(/\/(server|shared)\//, "")

        @metadata().templates[index] = content.toString()
        cb index

    finder = findit dirname

    # we received a file
    finder.on "file", (file, stat) =>
      files.push file

    # we received all files.
    finder.on "end", =>
      async.eachSeries files,
        readFile = (file, done) =>
          loadTemplateFile file, (index) =>
            App.Logger.info "Template #{index} loaded" if Salad.env is "development"
            done()

        # we are done!
        finished = (err) =>
          cb()

    # watch for changes and automatically reload files
    if Salad.env is "development"
      gaze "#{dirname}/*/*/*.hbs", (err, watcher) =>
        watcher.on "changed", (file) =>
          loadTemplateFile file, (index) =>
            App.Logger.info "Template #{index} reloaded"

  initDatabase: (cb) ->
    dbConfig = Salad.Config.database[Salad.env]

    App.sequelize = new Sequelize dbConfig.database, dbConfig.username, dbConfig.password,
      dialect: "postgres"
      host: dbConfig.host
      port: dbConfig.port
      logging: if Salad.env is "development" then console.log else false

    cb()

  initExpress: (cb) ->
    express = require "express"
    @metadata().app = express()

    @metadata().app.use express.bodyParser()
    @metadata().app.use express.methodOverride()
    @metadata().app.use express.static("#{Salad.root}/public")

    router = new Salad.Router
    @metadata().app.all "*", router.dispatch

    # TODO: Hack for this issue: https://github.com/sequelize/sequelize/issues/815
    # May need to think of a better way to handle this.
    # ATM, this will only try to create the tables, fail because they are already
    # created, but by trying will learn about the table structure.
    App.sequelize.sync()
      .success =>
        cb()

      .error =>
        cb()

  start: (callback) =>
    async.series [
      (cb) => @runTriggers "before:start", cb
      (cb) =>
        @metadata().expressServer = @metadata().app.listen @options.port

        console.log "Started salad. Environment: #{Salad.env}" if Salad.env isnt "testing"
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
