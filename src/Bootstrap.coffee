class Salad.Bootstrap
  _instance: null
  app: null

  options:
    routePath: "app/config/routes"
    controllerPath: "app/controllers"
    port: 80


  run: (options) ->
    @options.port = options.port || 80

    @initControllers()
    @initRoutes()
    @initHelpers()
    @initModels()

    @start()

  @instance: ->
    @_instance = new Salad.Bootstrap unless @_instance

    @_instance

  @run: (options) ->
    Salad.Bootstrap.instance().run options

  initRoutes: ->
    require "#{Salad.root}/#{@options.routePath}"

    console.log Salad.Router.getRoutes()

  initControllers: ->
    require("require-all")
      dirname: "#{Salad.root}/#{@options.controllerPath}"

  initHelpers: ->
  initModels: ->

  initMiddleware: ->


  start: ->
    @startExpress()

  startExpress: ->
    express = require "express"
    @app = express()

    Salad.Router.applyToExpress @app

    @app.listen @options.port