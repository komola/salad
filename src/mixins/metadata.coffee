module.exports =
  InstanceMethods:
    metadata: ->
      @__proto__.constructor._metadata or= {}

      @__proto__.constructor._metadata

  ClassMethods:
    metadata: ->
      @_metadata or= {}

      @_metadata