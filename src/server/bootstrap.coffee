global.Sequelize = require("sequelize")
global.async = require "async"
winston = require "winston"
findit = require "findit2"
fs = require "fs"
gaze = require "gaze"
path = require "path"
# require "longjohn"

class Salad.Bootstrap extends Salad.Base
  @extend require "./mixins/singleton"
  @mixin require "./mixins/metadata"
  @mixin require "./mixins/triggers"

  app: null

  options:
    routePath: "app/config/server/routes"
    controllerPath: "app/controllers/server"
    mailerPath: "app/mailers"
    modelPath: "app/models/server"
    configPath: "app/config/server/config"
    templatePath: ["app", "templates"].join(path.sep)
    publicPath: "public"
    port: 80
    env: "production"

  init: (options, callback) ->
    @constructor.before "init", @initConfig
    @constructor.before "init", @initLogger
    @constructor.before "init", @initControllers
    @constructor.before "init", @initMailers
    @constructor.before "init", @initRoutes
    @constructor.before "init", @initHelpers
    @constructor.before "init", @initDatabase
    @constructor.before "init", @initModels
    @constructor.before "init", @initTemplates
    @constructor.before "init", @initExpress

    @options.port = options.port || 80
    @options.env = Salad.env = options.env || "production"

    async.series [
      (cb) => @runTriggers "before:init", cb
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
      handleExceptions: false
      prettyPrint: true
      colorize: true
      timestamp: true
      level: "error"

    App.Logger = {}

    @metadata().logger.extend App.Logger

    App.Logger.log = =>
      for key, val of arguments
        if val instanceof Salad.Model
          arguments[key] = val.inspect()

      @metadata().logger.info.apply @, arguments

    App.Logger.error = =>
      for key, val of arguments
        if val instanceof Salad.Model
          arguments[key] = val.inspect()

      @metadata().logger.error.apply @, arguments

    if Salad.env isnt "test"
      console.log = App.Logger.log
      console.error = App.Logger.error

    cb()

  initRoutes: (cb) ->
    require "#{Salad.root}/#{@options.routePath}"

    cb()

  initControllers: (cb) ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.controllerPath}"
      filter: /\.coffee$/

    cb()

  initMailers: (cb) ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.mailerPath}"
      filter: /\.coffee$/

    cb()

  initHelpers: (cb) ->
    cb()

  initModels: (cb) ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.modelPath}"
      filter: /\.coffee$/

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
            content = @metadata().templates[index]
            Salad.Template.Handlebars.registerPartial index, content

            App.Logger.info "Template #{index} reloaded"

  initDatabase: (cb) ->
    dbConfig =
      dialect: "postgres"
      logging: false

    dbConfig = _.extend dbConfig, Salad.Config.database[Salad.env]

    # don't pass secret information to the extraConfig object
    extraConfig = _.omit dbConfig, "database", "username", "password"
    extraConfig.logging = if dbConfig.logging then console.log else false

    App.sequelize = new Sequelize dbConfig.database, dbConfig.username, dbConfig.password,
      extraConfig

    cb()

  initExpress: (cb) ->
    express = require "express"
    @metadata().app = express()

    @metadata().app.use express.responseTime()

    # put the static handler before the request logger because we don't want
    # to show all assets. In production environments static assets are probably
    # handled by nginx or something similar anyways
    @metadata().app.use express.static("#{Salad.root}/public")

    if Salad.env is "development"
      @metadata().app.use express.logger("dev")

    else if Salad.env is "production"
      @metadata().app.use express.logger()

    @metadata().app.use express.cookieParser()
    @metadata().app.use express.bodyParser()
    @metadata().app.use express.methodOverride()

    # TODO: Hack for this issue: https://github.com/sequelize/sequelize/issues/815
    # May need to think of a better way to handle this.
    # ATM, this will only try to create the tables, fail because they are already
    # created, but by trying will learn about the table structure.
    if Salad.env is "test"
      return cb()

    App.sequelize.sync()
      .success =>
        cb()

      .error =>
        cb()

  start: (callback) =>
    async.series [
      (cb) => @runTriggers "before:start", cb
      (cb) =>
        router = new Salad.Router
        @metadata().app.all "*", router.dispatch

        @metadata().app.use (err, req, res, next) ->
          console.error err.stack

          if Salad.env is "production"
            res.send 500, "Internal server error!"
          else
            res.type "text"
            res.send 500, err.stack

        @metadata().expressServer = @metadata().app.listen @options.port

        console.log "Started salad. Environment: #{Salad.env}" if Salad.env isnt "test"
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
