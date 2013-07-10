class Salad.RestfulController extends Salad.Controller
  @mixin require "./mixins/resource"
  @mixin require "./mixins/actions"

  constructor: ->
    @resourceOptions = @__proto__.constructor.resourceOptions

  _notFoundHandler: ->
    @response.status 404

    return @respond
      html: -> @response.send "Not found"
      json: -> @response.send status: 404
