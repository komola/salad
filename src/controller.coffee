class Salad.Controller extends Salad.Base
  _instance: null

  request: null
  response: null
  params: null

  @instance: ->
    @_instance = new @ unless @_instance

    @_instance
