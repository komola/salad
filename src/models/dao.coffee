Salad.DAO = {}

class Salad.DAO.Base
  daoModelInstance: undefined
  modelInstance: undefined

  constructor: (@daoModelInstance, @modelInstance) ->

  create: (attributes, callback) ->
  update: (model, changes, callback) ->
  findAll: (options, callback) ->

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
    params = {}

    if _.keys(options.conditions).length > 0
      params.where = options.conditions

    if options.limit > 0
      params.limit = options.limit

    if options.sorting.length > 0
      # transform the sorting params into i.e. 'name DESC'
      sorting = ("#{key} #{value.toUpperCase()}" for key, value of options.sorting)
      params.sorting = sorting.join ","

    if params.limit is -1
      delete params.limit

    if options.includes?.length > 0
      params.include = []
      for model in options.includes
        params.include.push model.daoModelInstance

    @daoModelInstance.findAll(params)
      .success (rawResources) =>
        resources = []

        for res in rawResources
          resources.push @_buildModelInstance res

        callback null, resources

  lazyInstantiate: (daoInstance) =>
    @_buildModelInstance daoInstance

  _cleanAttributes: (rawAttributes) =>
    attributes = {}
    attributes[key] = val for key, val of rawAttributes when val isnt undefined

    attributes

  _buildModelInstance: (daoInstance) =>
    options =
      isNew: false
      daoInstance: @
      eagerlyLoadedAssociations: {}

    if daoInstance.__eagerlyLoadedAssociations?.length > 0

      for key in daoInstance.__eagerlyLoadedAssociations
        associationModel = @modelInstance::associations[key]

        eagerLoadedModelInstance = associationModel.daoInstance.lazyInstantiate daoInstance[key]

        options.eagerlyLoadedAssociations[key] = eagerLoadedModelInstance

    attributes = daoInstance.dataValues

    return new @modelInstance attributes, options


# class Salad.DAO.Memory
#   store: {}

#   create: (attributes, callback) ->
#     @store[@daoModelInstance] or= []
#     @store[@daoModelInstance].push attributes

