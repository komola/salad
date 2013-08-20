class Salad.Controller extends Salad.Base
  @mixin require "./mixins/metadata"
  @mixin require "./mixins/triggers"
  @mixin require "./controllers/mixins/renderers"

  request: null
  response: null
  params: null

  @beforeAction: (callback) ->
    @_registerTrigger "beforeAction", callback

  @afterAction: (callback) ->
    @_registerTrigger "afterAction", callback

  redirectTo: (path) ->
    @response.redirect path

  findResource: (id, callback) =>
    @service.find id, (err, object) =>
      callback err, object