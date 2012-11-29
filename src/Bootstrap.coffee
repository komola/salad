class Salad.Bootstrap extends Salad.Base
  @extend "./mixins/Singleton"

  app: null

  options:
    routePath: "app/config/routes"
    controllerPath: "app/controllers"
    publicPath: "public"
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

    @configureExpress @app

    @app.listen @options.port

  configureExpress: (app) ->
    app.use "static", "#{Salad.root}/#{@options.publicPath}"
