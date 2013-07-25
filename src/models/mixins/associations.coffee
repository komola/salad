module.exports =
  InstanceMethods:
    getAssociations: ->
      _.clone @eagerlyLoadedAssociations

  ClassMethods:
    # register a hasMany association for this mdoel
    hasMany: (targetModel, options) ->
      # this is the method that we will create in this model
      getterName = "get#{options.as}"

      # this is the foreignKey field
      foreignKey = options.foreignKey

      # register the association
      @_registerAssociation options.as, targetModel

      # register attribute in targetModel
      targetModel.attribute foreignKey

      # register the method in this model
      # Don't bind to this context, because we want the method to be run in the
      # context of the instance
      @::[getterName] = ->
        conditions = {}
        conditions[foreignKey] = @get "id"

        scope = targetModel.scope()

        scope.where(conditions)

    # register a reverse-association in this model
    belongsTo: (targetModel, options) ->
      # this is the method that we will create in this model
      getterName = "get#{options.as}"

      foreignKey = options.foreignKey

      # register the association
      @_registerAssociation options.as, targetModel

      # @attributes[foreignKey] = undefined
      @attribute foreignKey

      # register the method in this model.
      # Don't bind to this context, because we want the method to be run in the
      # context of the instance
      @::[getterName] = ->
        conditions =
          id: @get foreignKey

        scope = targetModel.scope()

        scope.where(conditions)

    _registerAssociation: (key, model) ->
      key = key.toLowerCase()
      @::associations[key] = model

