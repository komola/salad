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

      sequelizeModel.updateAttributes(attributes, _.keys(attributes)).success (daoResource) =>
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

    # make a copy of the datavalues.
    # the possibly eagerloaded associations will be removed from this
    # object later because they are initialized in a different way
    dataValues = _.clone daoInstance.dataValues

    associationKeys = _.keys @modelClass.metadata().associations

    # TODO: When does this happen? Seems like dataValues is null
    for key in associationKeys when dataValues?[key]
      delete dataValues[key]

      # fetch the association model class from the associations object
      associationModelClass = @modelClass.getAssociation key
      associationType = @modelClass.getAssociationType key

      daoModels = daoInstance.dataValues[key]
      models = null

      if daoModels is null
        continue

      # create an instance of the associated model passing along our dao model instance
      if associationType is "belongsTo"
        daoModels = [daoModels]

      models = daoModels.map associationModelClass.daoInstance.lazyInstantiate

      # Unwrap the model from the array if it is a belongsTo association.
      # There can only be one association of this model
      if associationType is "belongsTo"
        models = models[0]

      # add the instance to the options, so the constructor of modelInstance
      # model can pick them up
      options.eagerlyLoadedAssociations[key] = models

    attributes = dataValues

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
      tableName = @modelClass.daoInstance.daoModelInstance.name

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
        if typeof model is "object" and model.as
          model.model = model.model.daoModelInstance
        else
          model = model.daoModelInstance

        params.include.push model

    return params

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
        sequelizeModel.increment(field, by: 1).success successCallback

      else
        sequelizeModel.increment(field, by: change).success successCallback

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
        sequelizeModel.decrement(field, by: 1).success successCallback

      else
        sequelizeModel.decrement(field, by: change).success successCallback
