class Salad.Controller extends Salad.Base
  @mixin require "./mixins/metadata"
  @mixin require "./controllers/mixins/renderers"

  request: null
  response: null
  params: null

  findResource: (id, callback) =>
    @service.find id, (err, object) =>
      callback err, object