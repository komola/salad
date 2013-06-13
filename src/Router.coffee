Router = require("barista").Router
router = new Router

class Salad.Router extends Salad.Base
  @extend "./mixins/Singleton"

  dispatch: (request, response) =>
    matching = router.first(request.path, request.method)

    # No matching route found
    unless matching
      matching =
        controller: "error"
        action: 404
        method: request.method

    # Get the matching controller
    controllerName = _.capitalize matching.controller
    controller = @_getMatchingController controllerName

    # Could not find associated controller
    unless controller
      controller = App.ErrorContoller.instance()

    if typeof controller[matching.action] is undefined
      controller = App.ErrorController.instance()
      matching.action = 404

    controller.response = response
    controller.params = _.extend request.query, request.body, matching

    # Call the controller action
    controller[matching.action]()

  @register: (cb) ->
    cb.apply @instance(), [router]

  _getMatchingController: (controllerName) ->
    controllerName = _.capitalize controllerName
    controller = App["#{controllerName}Controller"]

    unless controller
      throw new Error "Could not find 'App.#{controllerName}Controller'"

    controller = controller.instance()

    controller