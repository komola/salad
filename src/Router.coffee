Router = require("barista").Router
router = new Router

class Salad.Router extends Salad.Base
  @extend "./mixins/Singleton"

  # @match: (route, options) ->
  #   route =
  #     if options.via
  #       router.match(route, options.via)
  #     else
  #       router.match(route)

  #   route.to(options.to)


  @register: (cb) ->
    cb.apply @instance(), router

  dispatch: (request) ->
    console.log request

    # Get the matching route
    matching = router.first(request.path, request.method)

    # Get the controller that is linked with this route
    controller = @_getMatchingController matching.controller

    # Create request object and let the controller handle the request
    Salad.Request.Http.dispatch req, res, controller, matching.action

  _getMatchingController: (controllerName) ->
    controllerName = _s.capitalize controllerName
    controller = App["#{controllerName}Controller"]

    unless controller
      throw new Error "Could not find 'App.#{controllerName}Controller'"

    controller = controller.instance()

    controller


  # resource: (path, options) ->
  #   routes = [
  #     {
  #       method: "GET",
  #       path: path,
  #       options: {
  #         controller: options.controller,
  #         method: "index"}
  #     }
  #     {
  #       method: "GET",
  #       path: "#{path}/:#{path}Id",
  #       options: {
  #         controller: options.controller,
  #         method: "get"}
  #     }
  #     {
  #       method: "PUT",
  #       path: "#{path}/:#{path}Id",
  #       options: {
  #         controller: options.controller,
  #         method: "update"}
  #     }
  #     {
  #       method: "POST",
  #       path: "#{path}",
  #       options: {
  #         controller: options.controller,
  #         method: "create"
  #       }
  #     }
  #     {
  #       method: "DELETE",
  #       path: "#{path}/:#{path}Id",
  #       options: {
  #         controller: options.controller,
  #         method: "delete"
  #       }
  #     }
  #   ]

  #   for route in routes
  #     @add route.method, route.path, route.options
  #     @add route.method, "#{route.path}.:format", route.options

  # add: (method, path, options) ->
  #   @routes.push
  #     method: method
  #     path: path
  #     options: options

  # @getRoutes: -> @instance().getRoutes()

  # getRoutes: -> @routes

  # @applyToExpress: (app) ->
  #   routes = @getRoutes()

  #   @instance()._apply app, route for route in routes

  # _apply: (app, route) ->
  #   method = route.method.toLowerCase()

  #   controllerName = _s.capitalize route.options.controller
  #   controller = App["#{controllerName}Controller"]

  #   throw "Could not find 'App.#{controllerName}Controller'" unless controller

  #   controller = controller.instance()

  #   # console.log "Registering #{route.method} #{route.path} – App.#{controllerName}Controller::#{route.options.method}"

  #   app[method] route.path, (req, res) ->
  #     Salad.Request.Http.dispatch req, res, controller, route.options.method
