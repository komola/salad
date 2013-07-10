class Salad.Controller extends Salad.Base
  @extend require "./mixins/Singleton"

  request: null
  response: null
  params: null

  findResource: (id, callback) =>
    @service.find id, (err, object) =>
      callback err, object

  respond: (responders) ->
    format = @params.format or "html"

    format = "html" unless responders[format]

    responders[format].apply @