class Salad.Request.Http extends Salad.Request
  @dispatch: (req, res, controller, method) ->
    controller.params = req.params
    controller.request = req
    controller.response = res

    controller[method]()