class Salad.Scope
  context: undefined
  data:
    conditions: {}
    sorting: []
    limit: -1

  constructor: (@context) ->
    @data.conditions = {}
    @data.sorting = []
    @data.limit = -1

    @

  where: (attributes) =>
    for key, val of attributes
      @data.conditions[key] = val

    @

  asc: (field) =>
    @data.sorting.push
      field: field
      type: "asc"

    @

  desc: (field) =>
    @data.sorting.push
      field: field
      type: "desc"

    @

  limit: (limit) =>
    @data.limit = limit

    @

  all: (callback) =>
    options = @data

    @context.findAll options, callback

  first: (callback) =>
    options = @data
    options.limit = 1

    @context.findAll options, (err, resources) =>
      if resources instanceof Array
        resources = resources[0]

      return callback err, resources
