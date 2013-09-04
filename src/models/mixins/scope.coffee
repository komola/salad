## Data retrieval #####################################
## These are pretty much just proxy methods that insantiate
## a scope and pass the parameters on to the scope

module.exports =
  ClassMethods:
    # Builds a new scope with the current dao instance as context
    scope: ->
      return new Salad.Scope @

    where: (attributes) ->
      @scope().where attributes

    limit: (limit) ->
      @scope().limit limit

    offset: (offset) ->
      @scope().offset offset

    nil: (nil) ->
      @scope().nil()

    asc: (field) ->
      @scope().asc field

    desc: (field) ->
      @scope().desc field

    contains: (field, value) ->
      @scope().contains field, value

    includes: (models) ->
      @scope().includes models

    all: (callback) ->
      @scope().all callback

    first: (callback) ->
      @scope().first callback

    count: (callback) ->
      @scope().count callback

    find: (id, callback) ->
      @scope().find id, callback

    findAndCountAll: (callback) ->
      @scope().findAndCountAll callback

    destroy: (callback) ->
      @scope().destroy callback