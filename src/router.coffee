class Salad.Router
  routes: []
  _instance: null

  @instance: ->
    @_instance = new Salad.Router unless @_instance

    @_instance

  @register: (cb) ->
    cb.apply @instance()

  resource: (path, options) ->
    routes = [
      {
        method: "GET",
        path: path,
        options: {
          controller: options.controller,
          method: "index"}
      }
      {
        method: "GET",
        path: "#{path}/:#{path}Id",
        options: {
          controller: options.controller,
          method: "get"}
      }
      {
        method: "PUT",
        path: "#{path}/:#{path}Id",
        options: {
          controller: options.controller,
          method: "update"}
      }
      {
        method: "POST",
        path: "#{path}",
        options: {
          controller: options.controller,
          method: "create"
        }
      }
      {
        method: "DELETE",
        path: "#{path}/:#{path}Id",
        options: {
          controller: options.controller,
          method: "delete"
        }
      }
    ]

    @add route.method, route.path, route.options for route in routes

  add: (method, path, options) ->
    @routes.push
      method: method
      path: path
      options: options

  @getRoutes: -> @instance().getRoutes()

  getRoutes: -> @routes

  @applyToExpress: (app) ->
    routes = @getRoutes()

    @instance()._apply app, route for route in routes

  _apply: (app, route) ->
    method = route.method.toLowerCase()

    controllerName = _s.capitalize route.options.controller
    controller = App["#{controllerName}Controller"]

    throw "Could not find 'App.#{controllerName}Controller'" unless controller

    controller = controller.instance()

    # console.log "Registering #{route.method} #{route.path} – App.#{controllerName}Controller::#{route.options.method}"

    app[method] route.path, (req, res) ->
      Salad.Request.Http.dispatch req, res, controller, route.options.method
