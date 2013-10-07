Salad.DAO = {}

class Salad.DAO.Base
  daoModelInstance: undefined
  modelInstance: undefined

  constructor: (@daoModelInstance, @modelClass) ->

  create: (attributes, callback) ->
  update: (model, changes, callback) ->
  findAll: (options, callback) ->
  count: (options, callback) ->
  destroy: (model, callback) ->
  increment: (model, field, change, callback) ->
  decrement: (model, field, change, callback) ->

# class Salad.DAO.Memory
#   store: {}

#   create: (attributes, callback) ->
#     @store[@daoModelInstance] or= []
#     @store[@daoModelInstance].push attributes

