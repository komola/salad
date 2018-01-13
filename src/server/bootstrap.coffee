global.Sequelize = require("sequelize")
global.async = require "async"
winston = require "winston"
findit = require "findit2"
fs = require "fs"
gaze = require "gaze"
path = require "path"
responseTime = require("response-time")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
methodOverride = require("method-override")
morgan = require("morgan")

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
    @options.isCakefile = Salad.isCakefile = options.isCakefile || false

    async.series [
      (cb) => @runTriggers "before:init", cb
      (cb) => @runTriggers "after:init", cb
    ], (err) =>
      if err
        App.Logger.error err

      callback err if callback

  run: (options) ->
    @init options, (err) =>
      return if err

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
    @metadata().logger = new winston.Logger()
    @metadata().logger.setLevels(winston.config.syslog.levels)

    @metadata().logger.add winston.transports.Console,
      handleExceptions: false
      prettyPrint: true
      colorize: true
      timestamp: true
      level: "error"

    App.Logger = @metadata().logger

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

    if Salad.env isnt "test" and not Salad.isCakefile
      console.log = App.Logger.log
      console.error = App.Logger.error

    cb()

  initRoutes: (cb) ->
    require "#{Salad.root}/#{@options.routePath}"

    cb()

  # This helps to set up hot loading of changed files
  #
  # It works by deleting the cached require entry for the file and then
  # requiring it again.
  #
  # Afterwards we change the prototype of the old class, so that existing
  # instances get changed, too
  setupHotloadingInFolder: (folder, options, callback) =>
    if typeof(options) is "function"
      callback = options
      options = {}

    options or= {}

    gaze ["#{folder}/**/*.coffee", "#{folder}/**/*.js"], (err, watcher) =>
      watcher.on "changed", (file) =>
        if options.exclude and file.indexOf(options.exclude) isnt -1
          return

        console.log "File changed!", file

        # reload file. Map this in a try block because we are messing with
        # the global App variable
        try
          # save current global App state in temporary variable
          oldApp = global.App
          global.App = {}

          delete require.cache[require.resolve(file)]
          require file

          # detect which classes where changed. By requiring the file, it gets
          # a new entry in App and we can find out which class was changed
          changedClasses =  _.keys global.App

          # Iterate over all changed classes and detect if a method was deleted.
          for newClassName in changedClasses
            oldClass = oldApp[newClassName]
            newClass = global.App[newClassName]

            oldMethods = _.keys oldClass.prototype
            newMethods = _.keys newClass.prototype

            # If this is the case, delete the method from the existing instances
            for currentMethod in oldMethods when currentMethod not in newMethods
              # console.log "Deleting instance method #{currentMethod}"
              delete oldClass::[currentMethod]

            oldMethods = _.keys oldClass
            newMethods = _.keys newClass

            # Do the same with static methods
            for currentMethod in oldMethods when currentMethod not in newMethods
              # console.log "Deleting static method #{currentMethod}"
              delete oldClass[currentMethod]

            # Replace every old prototype method with the new version
            for methodName in _.keys newClass.prototype when typeof(newClass::[methodName]) is "function"
              # console.log "Replacing instance method #{methodName}"
              oldClass::[methodName] = newClass::[methodName]

            # Do the same with static methods
            for methodName in _.keys newClass when typeof(newClass[methodName]) is "function"
              # console.log "Replacing static method #{methodName}"
              oldClass[methodName] = newClass[methodName]

            # FIXME: fat arrow functions don't seem to work.
            # I have no solution how to replace the bound methods, as they
            # are bound per instance when instantiating and I have no way to
            # access every instance
            #
            # Reference: http://stackoverflow.com/a/13687261/9535

          global.App = oldApp

        catch e
          global.App = oldApp
          console.log "Error ocurred. Just reload file"

          delete require.cache[require.resolve(file)]
          require file

        return callback null, file if callback


  initControllers: (cb) ->
    directory = "#{Salad.root}/#{@options.controllerPath}"
    require("require-all")
      dirname: directory
      filter: /\.coffee$/

    if Salad.env is "development"
      @setupHotloadingInFolder directory

    return cb()


  initMailers: (cb) ->
    directory = "#{Salad.root}/#{@options.mailerPath}"
    require("require-all")
      dirname: directory
      filter: /\.coffee$/

    if Salad.env is "development"
      @setupHotloadingInFolder directory

    cb()

  initHelpers: (cb) ->
    cb()

  initModels: (cb) ->
    directory = "#{Salad.root}/#{@options.modelPath}"
    require("require-all")
      dirname: directory
      filter: /\.coffee$/

    if Salad.env is "development"
      @setupHotloadingInFolder directory

    cb()

  initTemplates: (callback) ->
    # find all templates and save their content in a hash
    files = []
    @metadata().templates = {}

    dirname = [Salad.root, @options.templatePath].join(path.sep)

    unless fs.existsSync dirname
      throw new Error "Templates folder does not exist! #{dirname}"

    loadTemplateFile = (file, cb) =>
      fs.readFile file, (err, content) =>
        return cb err if err

        file = path.normalize(file)
        index = file
          .replace(path.normalize(dirname), "")
          .replace(/\\/g, "/")
          .replace(/\/(server|shared)\//, "")

        @metadata().templates[index] = content.toString()

        cb err, index

    async.series [
      (cb) =>
        finder = findit dirname

        # we received a file
        finder.on "file", (file, stat) =>
          files.push file

        # we received all files.
        finder.on "end", cb

      (cb) =>
        async.eachSeries files, loadTemplateFile, cb
    ], (err) =>
      return callback err

    # watch for changes and automatically reload files
    if Salad.env is "development"
      gaze "#{dirname}/*/*/*.hbs", (err, watcher) =>
        watcher.on "changed", (file) =>
          loadTemplateFile file, (err, index) =>
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

    @metadata().app.use responseTime()

    # put the static handler before the request logger because we don't want
    # to show all assets. In production environments static assets are probably
    # handled by nginx or something similar anyways
    @metadata().app.use express.static("#{Salad.root}/public")

    if Salad.env is "development"
      @metadata().app.use morgan("dev")

    else if Salad.env is "production"
      @metadata().app.use morgan("combined")

    @metadata().app.use cookieParser()
    @metadata().app.use bodyParser.urlencoded(extended: false)
    @metadata().app.use bodyParser.json()
    @metadata().app.use methodOverride()

    return cb()

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
