class Salad.DAO.Sequelize extends Salad.DAO.Base
  create: (attributes, callback) ->
    attributes = @_cleanAttributes attributes
    @daoModelInstance.create(attributes).success (daoResource) =>
      resource = @_buildModelInstance daoResource
      callback null, resource

  # TODO: Optimize this. Right now this would create an additional select and update
  # query for each update operation.
  # We could use a instance hash of all daoModel objects and then just update those
  _getSequelizeModelBySaladModel: (model, callback) ->
    @daoModelInstance.find(model.get("id")).success (sequelizeModel) =>
      unless sequelizeModel
        error = new Error "Could not find model with id: #{model.get("id")}"
        return callback error

      callback null, sequelizeModel

  update: (model, attributes, callback) ->
    @_getSequelizeModelBySaladModel model, (err, sequelizeModel) =>
      return callback err if err

      sequelizeModel.updateAttributes(attributes).success (daoResource) =>
        resource = @_buildModelInstance daoResource
        callback null, resource

  ###
  Destroy models in the database

  Usage:
    # destroy single instance
    App.Todo.first (err, todo) =>
      todo.destroy()

    # destroy all objects
    App.Todo.destroy (err) =>
      console.log "everything gone"
  ###
  destroy: (model, callback) ->
    if model instanceof Salad.Model
      @_getSequelizeModelBySaladModel model, (err, sequelizeModel) =>
        return callback err if err

        sequelizeModel.destroy().success =>
          callback null

    else
      sequelizeModel = @daoModelInstance

      # when no conditions are supplied we have to delete *every* object.
      # Sequelize does not seem to allow this, since it creates a faulty SQL
      # statement when passing {} as conditions.
      # so we add a where statement that matches every row
      if _.keys(model.conditions).length is 0
        model.conditions = "true = true"

      sequelizeModel.destroy(model.conditions)
        .success =>
          callback null
        .error =>
          console.log arguments

          callback()

  findAll: (options, callback) ->
    params = @_buildOptions options

    @daoModelInstance.findAll(params)
      .success (rawResources) =>
        resources = []

        for res in rawResources
          resources.push @_buildModelInstance res

        callback null, resources

  count: (options, callback) ->
    params = @_buildOptions options

    @daoModelInstance.count(params)
      .success (count) =>
        callback null, count

  lazyInstantiate: (daoInstance) =>
    @_buildModelInstance daoInstance

  _cleanAttributes: (rawAttributes) =>
    attributes = {}
    attributes[key] = val for key, val of rawAttributes when val isnt null

    attributes

  _buildModelInstance: (daoInstance) =>
    options =
      isNew: false
      daoInstance: @
      eagerlyLoadedAssociations: {}

    if daoInstance.__eagerlyLoadedAssociations?.length > 0
      for key in daoInstance.__eagerlyLoadedAssociations
        loadedAssociationsKey = key

        associations = @modelClass.metadata().associations

        # sequelize seems to use the tableName as the key for the eager-loaded
        # association. We need to map this key back to the property we defined
        # for the association. So we need to look up the key and match by model
        # class.
        # FIXME: This can lead to problems when a model has more than one
        # association with another model.
        for associationKey, association of associations
          if associationKey.toLowerCase() is key
            loadedAssociationsKey = associationKey
            break

        # fetch the association model class from the associations object
        associationModelClass = @modelClass.getAssociation loadedAssociationsKey

        daoModels = daoInstance[key]
        models = null

        if daoModels is null
          continue

        # create an instance of the associated model passing along our dao model instance
        if daoModels instanceof Array
          models = []

          for daoModel in daoModels
            models.push associationModelClass.daoInstance.lazyInstantiate daoModel

        else
          models = associationModelClass.daoInstance.lazyInstantiate daoModels

        # add the instance to the options, so the constructor of modelInstance
        # model can pick them up
        options.eagerlyLoadedAssociations[loadedAssociationsKey] = models

    attributes = daoInstance.dataValues

    return new @modelClass attributes, options

  _buildOptions: (options) ->
    params = {}

    if _.keys(options.conditions).length > 0
      params.where = options.conditions

    if options.limit > 0
      params.limit = options.limit

    if options.offset > 0
      params.offset = options.offset

    if options.order.length > 0
      # transform the order params into i.e. 'name DESC'
      order = []
      for elm in options.order
        order.push [
          # BUG this will cause problems with mysql drivers because the
          # escaping is off
          "\"#{elm.field}\""
          elm.type.toUpperCase()
        ]

      params.order = order

    if options.contains.length > 0
      tableName = @modelClass.daoInstance.daoModelInstance.tableName
      attribs = ("'#{contains.value}' = ANY(\"#{tableName}\".\"#{contains.field}\")" for contains in options.contains)

      if params.where
        for key, val of params.where
          queryGenerator = @daoModelInstance.daoFactoryManager.sequelize.queryInterface.QueryGenerator
          # quote column
          key = queryGenerator.quoteIdentifier key
          # make sure to escape the value
          val = queryGenerator.escape val

          attribs.push "#{key} = #{val}"

      params.where = attribs.join " AND "

    if params.limit is -1
      delete params.limit

    if options.includes?.length > 0
      params.include = []
      for model in options.includes
        params.include.push model.daoModelInstance
    params

  ###
  Increment the field of a model.

  This prevents concurrency issues

  Usage:
    App.Model.first (err, model) =>
      model.increment "field", 3, (err, newModel) =>
        console.log model.get("field") is newModel.get("field") # => true
  ###
  increment: (model, field, change, callback) =>
    @_getSequelizeModelBySaladModel model, (err, sequelizeModel) =>
      return callback err if err

      successCallback = (daoResource) =>
        resource = @_buildModelInstance daoResource

        callback null, resource

      if typeof field is "object"
        sequelizeModel.increment(field).success successCallback

      else
        sequelizeModel.increment(field, change).success successCallback

  ###
  Decrement the field of a model

  This prevents concurrency issues

  Usage:
    App.Model.first (err, model) =>
      model.decrement "field", 3, (err, newModel) =>
        console.log model.get("field") is newModel.get("field") # => true
  ###
  decrement: (model, field, change, callback) =>
    @_getSequelizeModelBySaladModel model, (err, sequelizeModel) =>
      successCallback = (daoResource) =>
        resource = @_buildModelInstance daoResource

        callback null, resource

      if typeof field is "object"
        sequelizeModel.decrement(field).success successCallback

      else
        sequelizeModel.decrement(field, change).success successCallback
