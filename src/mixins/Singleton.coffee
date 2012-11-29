module.exports =
  _instance: null

  instance: ->
    @_instance = new @ unless @_instance

    @_instance