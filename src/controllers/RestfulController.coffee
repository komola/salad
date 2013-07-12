class Salad.RestfulController extends Salad.Controller
  @mixin require "./mixins/renderers"
  @mixin require "./mixins/resource"
  @mixin require "./mixins/actions"
  @mixin require "./mixins/pagination"

  constructor: ->
    @resourceOptions = @__proto__.constructor.resourceOptions

