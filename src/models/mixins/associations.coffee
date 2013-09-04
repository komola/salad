module.exports =
  InstanceMethods:
    getAssociations: ->
      _.clone @eagerlyLoadedAssociations

  ClassMethods:
    # register a hasMany association for this mdoel
    # Usage
    #   App.Parent.hasMany App.Children, as: "Children", foreignKey: "parentId"
    hasMany: (targetModel, options) ->
      # this is the method that we will create in this model
      getterName = "get#{options.as}"

      # this is the foreignKey field
      foreignKey = options.foreignKey

      # register the association
      @_registerAssociation options.as, targetModel, isOwning: false

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
      @_registerAssociation options.as, targetModel, isOwning: true

      @attribute foreignKey

      # register the method in this model.
      # Don't bind to this context, because we want the method to be run in the
      # context of the instance
      @::[getterName] = ->
        conditions =
          id: @get foreignKey

        scope = targetModel.scope()

        scope.where(conditions)

    # return the model class for the association key name
    getAssociation: (key) ->
      @metadata().associations[key].model

    _registerAssociation: (key, model, options = {}) ->
      key = key.toLowerCase()

      @metadata().associations or= {}
      @metadata().associations[key] =
        model: model
        isOwning: options.isOwning
