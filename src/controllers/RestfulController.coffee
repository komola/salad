class Salad.RestfulController extends Salad.Controller
  index: ->
    @respond
      html: -> "Hi!"
      json: -> JSON.stringify foo: "bar"

  read: ->
    @findResource @params.id, (err, object) =>
      @respond
        json: -> JSON.stringify object
        html: -> "Hallo!"

  update: ->

  delete: ->