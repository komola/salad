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
        error = new Error "Could not find model with id: #{model.attributes.id}"
        return callback error

      callback null, sequelizeModel

  update: (model, attributes, callback) ->
    @_getSequelizeModelBySaladModel model, (err, sequelizeModel) =>
      return callback err if err

      sequelizeModel.updateAttributes(attributes).success (daoResource) =>
        resource = @_buildModelInstance daoResource
        callback null, resource

  destroy: (model, callback) ->
    @_getSequelizeModelBySaladModel model, (err, sequelizeModel) =>
      return callback err if err

      sequelizeModel.destroy().success =>
        callback null

  findAll: (options, callback) ->
    params = @_buildOptions options

    # TODO do performance tests on how faster this is
    params.raw = true

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
        # fetch the association model class from the associations object
        associationModelClass = @modelClass.getAssociation key

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
        options.eagerlyLoadedAssociations[key] = models

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
      order = ("#{elm.field} #{elm.type.toUpperCase()}" for elm in options.order)
      params.order = order.join ","

    if options.contains.length > 0
      attribs = ("'#{contains.value}' = ANY(\"#{contains.field}\")" for contains in options.contains)

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