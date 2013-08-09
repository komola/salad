class Salad.Scope
  constructor: (@context) ->
    @daoContext = @context.daoInstance
    @data =
      conditions: {}
      contains: []
      includes: []
      order: []
      limit: -1
      offset: 0

  where: (attributes) ->
    unless typeof(attributes) is "object"
      throw new Error "where() only accepts an object as argument!"

    for key, val of attributes
      @data.conditions[key] = val

    @

  asc: (field) ->
    @data.order.push
      field: field
      type: "asc"

    @

  desc: (field) ->
    @data.order.push
      field: field
      type: "desc"

    @

  contains: (field, value) ->
    @data.contains.push
      field: field
      value: value

    @

  include: (models) ->
    for model in models
      unless model.daoInstance
        throw new Error "Model has to be instance of Salad.Model! #{model}"

      @data.includes.push model.daoInstance

    @

  limit: (limit) ->
    @data.limit = parseInt limit, 10

    @

  offset: (offset) ->
    @data.offset = parseInt offset, 10

    @

  count: (callback) ->
    options = _.clone @data
    if options.offset
      delete options.offset

    if options.includes
      delete options.includes

    @daoContext.count options, callback

  all: (callback) ->
    options = @data

    @daoContext.findAll options, callback

  first: (callback) ->
    options = @data
    options.limit = 1

    @daoContext.findAll options, (err, resources) =>
      if resources instanceof Array
        resources = resources[0]

      return callback err, resources

  find: (id, callback) ->
    @where(id: id).first callback

  findAndCountAll: (callback) ->

    @all (err, resources) =>
      @count (err, count) =>
        result =
          count: count
          rows: resources

        callback err, result

  ## Creation

  create: (data, callback) ->
    attributes = _.extend @data.conditions, data

    @context.create attributes, callback

  build: (data) ->
    attributes = _.extend @data.conditions, data

    @context.build attributes

  remove: (model, callback) ->
    keys = _.keys @data.conditions

    updateData = {}
    for key in keys
      updateData[key] = undefined

    model.setAttributes updateData

    model.save callback