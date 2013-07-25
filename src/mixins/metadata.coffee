module.exports =
  InstanceMethods:
    metadata: ->
      @__proto__.constructor.metadata or= {}

      @__proto__.constructor.metadata

  ClassMethods:
    metadata: ->
      @metadata or= {}

      @metadata

