class Salad.RestfulController extends Salad.Controller
  resourceName: ""


  index: ->
    @respond
      html: -> "Hi!"
      json: -> JSON.stringify foo: "bar"

  findResourceById: (cb) =>
    @findResource @params["#{@resourceName}Id"], cb

  read: ->
    @findResourceById =>
      @respond
        html: -> "Hallo!"
        json: -> JSON.stringify object

  update: ->
    @findResourceById =>
      object.updateAttributes @params, =>
        @respond
          html: -> "Yo success"
          json: -> JSON.stringify object

  delete: ->
    @findResourceById =>
      object.destroy =>
        @respond
          html: -> "Deleted"
          json: -> JSON.stringify object