global.Sequelize = require("sequelize-sqlite").sequelize
sqlite = require("sequelize-sqlite").sqlite
async = require "async"
winston = require "winston"

class Salad.Bootstrap extends Salad.Base
  @extend "./mixins/Singleton"

  app: null

  options:
    routePath: "app/config/server/routes"
    controllerPath: "app/controllers/server"
    modelPath: "app/models/server"
    publicPath: "public"
    port: 80
    env: "production"

  run: (options) ->
    @options.port = options.port || 80
    @options.env = options.env || "production"

    @initLogger()
    @initControllers()
    @initRoutes()
    @initHelpers()
    @initDatabase()
    @initModels()

    @initExpress()

    @start(options.cb)

  @run: (options) ->
    options or= {}

    Salad.Bootstrap.instance().run options

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
    App.sequelize = new Sequelize "salad-example", "root", "",
      dialect: "sqlite"
      storage: "#{Salad.root}/db.sqlite"
      logging: Salad.env is "development"

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
    syncSequelize = (cb) =>
      App.sequelize.sync(force: true).done cb

    listen = (cb) =>
      @expressServer = @app.listen @options.port
      cb()

    async.series [syncSequelize, listen], =>
      callback.apply @ if callback

  @destroy: (callback) ->
    @instance().destroy callback

  destroy: (callback) ->
    stopExpress = (cb) =>
      @expressServer.close cb

    async.series [stopExpress], =>
      callback.apply @ if callback