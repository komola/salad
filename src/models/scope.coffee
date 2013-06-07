class Salad.Scope
  context: undefined
  conditions: {}
  sorting: []
  limit: -1

  constructor: (@context) ->

  where: (attributes) =>
    for key, val of attributes
      @conditions[key] = val

    @

  asc: (field) =>
    @sorting.push
      field: field
      type: "asc"

    @

  desc: (field) =>
    @sorting.push
      field: field
      type: "desc"

    @

  limit: (limit) ->
    @limit = limit

    @

  all: (callback) =>
    options =
      conditions: @conditions
      sorting: @sorting
      limit: @limit

    @context.findAll options, callback

  first: (callback) =>
    options =
      conditions: @conditions
      sorting: @sorting
      limit: 1

    @context.findAll options, (err, resources) =>
      if resources instanceof Array
        resources = resources[0]

      return callback err, resources
