class Salad.DAO.Sequelize extends Salad.DAO.Base
  create: (attributes, callback) ->
    attributes = @_cleanAttributes attributes
    options = {}

    if App.transaction
      options.transaction = App.transaction

    query = @daoModelInstance.create(attributes, options)

    query.success (daoResource) =>
      resource = @_buildModelInstance daoResource
      return callback null, resource

    query.error (error) =>
      if Salad.env isnt "test"
        App.Logger.error "Create: Query returned error",
          sql: error.sql
          attributes: attributes
        App.Logger.error error

      return callback error

  # TODO: Optimize this. Right now this would create an additional select and update
  # query for each update operation.
  # We could use a instance hash of all daoModel objects and then just update those
  _getSequelizeModelBySaladModel: (model, callback) ->
    options = {}

    if App.transaction
      options.transaction = App.transaction

    conditions =
      where:
        id: model.get("id")

    query = @daoModelInstance.find(conditions, options)

    query.success (sequelizeModel) =>
      unless sequelizeModel
        error = new Error "Could not find model with id: #{model.get("id")}"
        return callback error

      return callback null, sequelizeModel

    query.error (error) =>
      if Salad.env isnt "test"
        App.Logger.error "Find: Query returned error",
          sql: error.sql
          conditions: conditions
        App.Logger.error error

      return callback error

  update: (model, attributes, callback) ->
    @_getSequelizeModelBySaladModel model, (err, sequelizeModel) =>
      return callback err if err

      options =
        fields: _.keys(attributes)

      if App.transaction
        options.transaction = App.transaction

      query = sequelizeModel.updateAttributes(attributes, options)

      query.success (daoResource) =>
        resource = @_buildModelInstance daoResource
        callback null, resource

      query.error (error) =>
        if Salad.env isnt "test"
          App.Logger.error "Update: Query returned error",
            sql: error.sql
            attributes: attributes
            options: _.omit options, "transaction"

          App.Logger.error error

        return callback error

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

        options = {}

        if App.transaction
          options.transaction = App.transaction

        query = sequelizeModel.destroy(options)

        query.success =>
          callback null

        query.error (error) =>
          if Salad.env isnt "test"
            App.Logger.error "Destroy: Query returned error",
              sql: error.sql
            App.Logger.error error

          return callback error

    else
      sequelizeModel = @daoModelInstance

      # when no conditions are supplied we have to delete *every* object.
      # Sequelize does not seem to allow this, since it creates a faulty SQL
      # statement when passing {} as conditions.
      # so we add a where statement that matches every row
      if _.keys(model.conditions).length is 0
        model.conditions = "true = true"

      options = {}

      if App.transaction
        options.transaction = App.transaction

      query = sequelizeModel.destroy(model.conditions, options)

      query.success =>
        callback null

      query.error (error) =>
        if Salad.env isnt "test"
          App.Logger.error "Query returned error",
            sql: error.sql
          App.Logger.error error

        return callback error

  findAll: (options, callback) ->
    params = @_buildOptions options

    if App.transaction
      params.transaction = App.transaction

    query = @daoModelInstance.findAll(params)

    query.success (rawResources) =>
      resources = []

      for res in rawResources
        resources.push @_buildModelInstance res

      callback null, resources

    query.error (error) =>
      if Salad.env isnt "test"
        App.Logger.error "findAll: Query returned error",
          sql: error.sql
          parameter: params
        App.Logger.error error

      return callback error

  count: (options, callback) ->
    params = @_buildOptions options

    if App.transaction
      params.transaction = App.transaction

    query = @daoModelInstance.count(params)

    query.success (count) =>
        callback null, count

    query.error (error) =>
      if Salad.env isnt "test"
        App.Logger.error "Count: Query returned error",
          sql: error.sql
          parameter: params
        App.Logger.error error

      return callback error

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


    associationKeys = _.pluck @modelClass.metadata().associations, "as"

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

      key = key[0].toLowerCase() + key.substr(1)

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
      for option in options.includes
        if typeof option is "object" and option.as
          option.model = option.model.daoModelInstance

        params.include.push option

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

      options = {}

      if typeof field is "object"
        options.by = 1
      else
        options.by = change

      if App.transaction
        options.transaction = App.transaction

      sequelizeModel.increment(field, options).success successCallback

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
      return callback err if err

      successCallback = (daoResource) =>
        resource = @_buildModelInstance daoResource

        callback null, resource

      options = {}

      if typeof field is "object"
        options.by = 1
      else
        options.by = change

      if App.transaction
        options.transaction = App.transaction

      sequelizeModel.decrement(field, options).success successCallback
