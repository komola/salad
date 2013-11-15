module.exports =
  InstanceMethods:
    getAssociations: ->
      _.clone @eagerlyLoadedAssociations

    hasAssociation: (key) ->
      @constructor.hasAssociation key

    getAssociation: (key) ->
      @constructor.getAssociation key

    getAssociationType: (key) ->
      @constructor.getAssociationType key

    setAssociation: (key, serializedModel) ->
      unless serializedModel instanceof Array
        serializedModel = [serializedModel]

      # Make sure that the serialized models are all resolved to model instances
      models = serializedModel.map (model) =>
        return model if model instanceof Salad.Model
        return @getAssociation(key).build model

      if @getAssociationType(key) is "hasMany"
        @eagerlyLoadedAssociations[key] = models

      else
        @eagerlyLoadedAssociations[key] = models[0]

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
      @_registerAssociation options.as, targetModel,
        isOwning: false
        type: "hasMany"

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
      @_registerAssociation options.as, targetModel,
        isOwning: true
        type: "belongsTo"

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

    getAssociationType: (key) ->
      @metadata().associations[key].type

    hasAssociation: (key) ->
      @metadata().associations[key] isnt undefined

    _registerAssociation: (key, model, options = {}) ->
      key = key[0].toLowerCase() + key.substr(1)

      @metadata().associations or= {}
      @metadata().associations[key] =
        model: model
        isOwning: options.isOwning
        type: options.type
