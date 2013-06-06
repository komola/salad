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
    @daoModelInstance.create(attributes).success (resource) =>
      callback null, resource

  update: (model, attributes, callback) ->
    @daoModelInstance.find(model.id).success (sequelizeModel) ->
      sequelizeModel.set sequelizeModel.attributes
      sequelizeModel.save callback

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
          attributes = res.dataValues
          options =
            isNew: false
            daoInstance: @

          resources.push new @modelInstance attributes, options

        callback null, resources

# class Salad.DAO.Memory
#   store: {}

#   create: (attributes, callback) ->
#     @store[@daoModelInstance] or= []
#     @store[@daoModelInstance].push attributes

