global.Sequelize = require("sequelize-postgres").sequelize
postgres = require("sequelize-postgres").postgres
async = require "async"
winston = require "winston"
require "longjohn"

class Salad.Bootstrap extends Salad.Base
  @extend "./mixins/Singleton"

  app: null

  options:
    routePath: "app/config/server/routes"
    controllerPath: "app/controllers/server"
    modelPath: "app/models/server"
    configPath: "app/config/server/config"
    publicPath: "public"
    port: 80
    env: "production"

  init: (options) ->
    @options.port = options.port || 80
    @options.env = Salad.env = options.env || "production"

    @initConfig()

    @initLogger()
    @initControllers()
    @initRoutes()
    @initHelpers()
    @initDatabase()
    @initModels()

    @initExpress()

  run: (options) ->
    @init options

    @start(options.cb)

  @run: (options) ->
    options or= {}

    Salad.Bootstrap.instance().run options

  initConfig: ->
    # Salad.Config = require("require-all")
    #   dirname: "#{Salad.root}/#{@options.configPath}"

    # TODO: Allow more than one file and external configuration, i.e.
    # in the /etc folder
    Salad.Config = require "#{Salad.root}/#{@options.configPath}"

  initLogger: ->
    logger = new winston.Logger
    logger.setLevels winston.config.syslog.levels

    logger.add winston.transports.Console,
      handleExceptions: true
      prettyPrint: true
      colorize: true
      timestamp: true

    App.Logger = {}

    logger.extend App.Logger

    App.Logger.log = ->
      logger.info.apply @, arguments

    if Salad.env isnt "testing"
      console.log = App.Logger.log
      console.error = App.Logger.error

  initRoutes: ->
    require "#{Salad.root}/#{@options.routePath}"

  initControllers: ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.controllerPath}"

  initHelpers: ->
  initModels: ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.modelPath}"

  initDatabase: ->
    dbConfig = Salad.Config.database[Salad.env]

    App.sequelize = new Sequelize dbConfig.database, dbConfig.username, dbConfig.password,
      dialect: "postgres"
      host: dbConfig.host
      port: dbConfig.port
      logging: if Salad.env is "development" then console.log else false
      omitNull: true

  initMiddleware: ->

  initExpress: ->
    express = require "express"
    @app = express()

    @app.use express.bodyParser()
    @app.use express.methodOverride()
    @app.use express.static("#{Salad.root}/public")

    router = new Salad.Router
    @app.all "*", router.dispatch

  start: (callback) =>
    startExpress = (cb) =>
      @expressServer = @app.listen @options.port
      cb()

    async.series [startExpress], =>
      callback.apply @ if callback

  @destroy: (callback) ->
    @instance().destroy callback

  destroy: (callback) ->
    stopExpress = (cb) =>
      @expressServer.close cb

    async.series [stopExpress], =>
      callback.apply @ if callback