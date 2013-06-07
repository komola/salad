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
    @daoModelInstance.create(attributes).success (daoResource) =>
      resource = @_buildModelInstance daoResource
      callback null, resource

  update: (model, attributes, callback) ->
    @daoModelInstance.find(model.attributes.id).success (sequelizeModel) =>
      unless sequelizeModel
        error = new Error "Could not find model with id: #{model.attributes.id}"
        return callback error

      sequelizeModel.updateAttributes(attributes).success (daoResource) =>
        resource = @_buildModelInstance daoResource
        callback null, resource

  findAll: (options, callback) ->
    params = {}

    if options.conditions.length > 0
      params.where = options.conditions

    if options.limit > 0
      params.limit = options.limit

    if options.sorting.length > 0
      # transform the sorting params into i.e. 'name DESC'
      sorting = ("#{key} #{value.toUpperCase()}" for key, value of options.sorting)
      params.sorting = sorting.join ","

    if params.limit is -1
      delete params.limit

    @daoModelInstance.findAll(params)
      .success (rawResources) =>
        resources = []

        for res in rawResources
          resources.push @_buildModelInstance res

        callback null, resources

  _buildModelInstance: (daoInstance) =>
    attributes = daoInstance.dataValues
    options =
      isNew: false
      daoInstance: @

    return new @modelInstance attributes, options


# class Salad.DAO.Memory
#   store: {}

#   create: (attributes, callback) ->
#     @store[@daoModelInstance] or= []
#     @store[@daoModelInstance].push attributes

