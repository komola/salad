class Salad.Controller extends Salad.Base
  @extend "./mixins/Singleton"

  request: null
  response: null
  params: null

  findResource: (id, callback) =>
    @service.find id, (err, object) =>
      callback err, object

  respond: (responders) ->
    format = @params.format || "html"

    format = "html" unless responders[format]

    @response.send responders[format]()