class Salad.DAO.Sequelize extends Salad.DAO.Base
  create: (attributes, callback) ->
    attributes = @_cleanAttributes attributes
    @daoModelInstance.create(attributes).success (daoResource) =>
      resource = @_buildModelInstance daoResource
      callback null, resource

  update: (model, attributes, callback) ->
    @daoModelInstance.find(model.get("id")).success (sequelizeModel) =>
      unless sequelizeModel
        error = new Error "Could not find model with id: #{model.attributes.id}"
        return callback error

      sequelizeModel.updateAttributes(attributes).success (daoResource) =>
        resource = @_buildModelInstance daoResource
        callback null, resource

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
        # fetch the association model class from the associations object
        associationModelClass = @modelClass::associations[key]

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

    if options.sorting.length > 0
      # transform the sorting params into i.e. 'name DESC'
      sorting = ("#{sort.field} #{sort.type.toUpperCase()}" for sort in options.sorting)
      params.sorting = sorting.join ","

    if options.contains.length > 0
      attribs = ("'#{contains.value}' = ANY(\"#{contains.field}\")" for contains in options.contains)

      if params.where
        throw new Error "Can not use #contains in combination with .where(). This is not supported yet!"

      params.where = attribs.join ","

    if params.limit is -1
      delete params.limit

    if options.includes?.length > 0
      params.include = []
      for model in options.includes
        params.include.push model.daoModelInstance

    params