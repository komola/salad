Salad.DAO = {}

class Salad.DAO.Base
  daoModelInstance: undefined
  modelInstance: undefined

  constructor: (@daoModelInstance, @modelClass) ->

  create: (attributes, callback) ->
  update: (model, changes, callback) ->
  findAll: (options, callback) ->
  count: (options, callback) ->

# class Salad.DAO.Memory
#   store: {}

#   create: (attributes, callback) ->
#     @store[@daoModelInstance] or= []
#     @store[@daoModelInstance].push attributes

