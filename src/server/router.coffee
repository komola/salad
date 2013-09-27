Router = require("barista").Router
path = require "path"

router = new Router

# write our own salad-compatible resource method.
# salad needs routes in this form: resources/:resourceId, barista
# creates them in this format: resources/:id
router.resource = (path, controller, resourceName) ->
  # router.get("/"+controller).to(controller+".index")

  router.get('/'+path+'(.:format)', 'GET').to(controller+'.index')
  router.post('/'+path+'(.:format)', 'POST').to(controller+'.create')
  router.get('/'+path+'/add(.:format)', 'GET').to(controller+'.add')

  router.get('/'+path+'/:'+resourceName+'Id(.:format)', 'GET').to(controller+'.show')
  router.get('/'+path+'/:'+resourceName+'Id/edit(.:format)', 'GET').to(controller+'.edit')
  router.put('/'+path+'/:'+resourceName+'Id(.:format)', 'PUT').to(controller+'.update')
  router.del('/'+path+'/:'+resourceName+'Id(.:format)', 'DELETE').to(controller+'.destroy')

class Salad.Router extends Salad.Base
  @extend require "./mixins/singleton"

  # Dispatch the request to the associated controller
  dispatch: (request, response) =>
    requestPath = path.normalize request.path

    # remove trailing slashes
    if _.last(requestPath) is "/" and requestPath isnt "/"
      requestPath = requestPath.substr 0, requestPath.length - 1

    # Get the first matching route
    matching = router.first(requestPath, request.method)
    # default format is html"
    matching.format or= "html"

    # No matching route found
    unless matching
      matching =
        controller: "error"
        action: 404
        method: request.method

    # Get the matching controller
    controllerName = _.capitalize matching.controller
    controllerName = "#{controllerName}Controller"
    controller = @_getMatchingController controllerName

    # Could not find associated controller
    unless controller
      unless App.ErrorContoller
        throw new Error "Tried to use App.ErrorController but it does not exist. Please create an ErrorController to show error messages!"
      controller = App.ErrorContoller.instance()

    # Action does not exist in the controller
    if typeof controller[matching.action] is undefined
      controller = App.ErrorController.instance()
      matching.action = 404

    # Parse Accept header to determine which response format to use
    if acceptHeader = request.headers.accept
      if acceptHeader.indexOf("application/json") isnt -1
        matching.format = "json"

    # Pass request and response objects on to the controller instance
    controller.response = response
    controller.request = request
    controller.params = _.extend request.query, request.body, matching

    # Call the controller action
    async.series [
        (cb) =>
          # do not log request information in testing
          return cb() if Salad.env is "testing"

          # output dispatching information
          line = "Dispatching request: #{controllerName}.#{matching.action} (#{matching.format})"
          App.Logger.log line, controller.params
          cb()

        (cb) => controller.runTriggers "beforeAction", cb
        (cb) => controller.runTriggers "before:#{matching.action}", cb
        (cb) =>
          # call the action on our controller
          controller[matching.action]()
          cb()
        # wait for the request to finish, so that we can trigger the after actions
        (cb) =>
          # don't wait for the render event when the response is already finished
          # this happens when the action does not contain any db calls etc.
          if response.finished
            return cb()

          controller.on "render", cb
        (cb) => controller.runTriggers "after:#{matching.action}", cb
        (cb) => controller.runTriggers "afterAction", cb
      ],

      # finished dispatching the request
      (err) =>

  _getMatchingController: (controllerName) ->
    controllerName = _.capitalize controllerName
    controller = App[controllerName]

    unless controller
      throw new Error "Could not find 'App.#{controllerName}'"

    controller = new controller

    controller

  ###
  Usage:
    Salad.Router.register (router) ->
      router.match("/path").to("controller.action")

  ###
  @register: (cb) ->
    cb.apply @instance(), [router]
