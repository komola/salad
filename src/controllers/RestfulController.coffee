class Salad.RestfulController extends Salad.Controller
  @mixin require "./mixins/renderers"
  @mixin require "./mixins/resource"
  @mixin require "./mixins/actions"

  constructor: ->
    @resourceOptions = @__proto__.constructor.resourceOptions

