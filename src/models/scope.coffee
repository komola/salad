class Salad.Scope
  context: undefined
  data:
    conditions: {}
    sorting: []
    limit: -1

  constructor: (@context) ->
    @daoContext = @context.daoInstance

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

    @daoContext.findAll options, callback

  first: (callback) =>
    options = @data
    options.limit = 1

    @daoContext.findAll options, (err, resources) =>
      if resources instanceof Array
        resources = resources[0]

      return callback err, resources

  ## Creation

  create: (data, callback) =>
    attributes = _.extend @data.conditions, data

    @context.create attributes, callback

  build: (data) =>
    attributes = _.extend @data.conditions, data

    @context.build attributes