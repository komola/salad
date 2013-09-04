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

  ###
  Usage:
    # id has to equal "value"
    scope.where(id: "value")

    # id has to be IN [1, 2, 3]
    scope.where(id: [1, 2, 3])
  ###
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

  includes: (models) ->
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

  nil: ->
    @data.nil = true

    @

  count: (callback) ->
    options = _.clone @data, true

    if options.nil
      return callback null, 0

    if options.offset
      delete options.offset

    if options.includes
      delete options.includes

    if options.limit
      delete options.limit

    @daoContext.count options, callback

  all: (callback) ->
    options = @data

    if options.nil
      return callback null, []

    @daoContext.findAll options, callback

  first: (callback) ->
    options = @data
    options.limit = 1

    @all (err, resources) =>
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

  # create object
  create: (data, callback) ->
    attributes = _.extend @data.conditions, data

    @context.create attributes, callback

  # build an instance
  build: (data) ->
    attributes = _.extend @data.conditions, data

    @context.build attributes

  destroy: (callback) ->
    options = @data

    @daoContext.destroy options, callback

  # remove associations
  remove: (model, callback) ->
    keys = _.keys @data.conditions

    updateData = {}
    for key in keys
      updateData[key] = undefined

    model.setAttributes updateData

    model.save callback