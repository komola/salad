class Salad.Bootstrap
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

_.extend Salad.Bootstrap, require "./mixins/Singleton"