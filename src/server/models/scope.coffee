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

  _normalizeInclude: (include) ->
    # includes should always have one of the following forms:
    # {model: Operator, …} where Operator is a subclass of Salad.Model
    # {association: "Operators", …} where the association has been registered before
    # however we allow calls like Scope.includes([Operator]) or Scope.includes(["Operators"])
    # this method transforms the last forms to the normal form
    # NO sanity checking is happening in this method

    if include is null or include is undefined
      throw new Error "Scope::includes - Value of include must not be null"

    if typeof include is "string"
      # this must be an association
      return {association: include}
    else if include.__super__ is Salad.Model.prototype
      return {model: include}

    include


  # Eager-load models
  #
  # Usage:
  #
  # App.Location.includes([App.Operator])
  #
  # App.Location.includes(["Operator"])
  #
  # App.Location.includes([{model: App.Operator, includes: [App.Cat]}])
  #
  # App.Location.includes([{association: "Operators", includes: ["Cats"]}]
  #
  # or a mix of the last two
  includes: (includesArray) ->
    for include in includesArray
      option = {}
      field = null
      includes = []

      saladModel = {}

      include = @_normalizeInclude include

      if include.model
        unless include.model.__super__ is Salad.Model.prototype
          throw new Error "Scope::includes - Value of key 'model' has to be of type Salad.Model"

        model = include.model
        associations = @context.metadata().associations

        for key, currentAssociation of associations when currentAssociation.model is model
          field = currentAssociation.as
          break
        saladModel = model
        model = model.daoInstance

      else if include.association
        unless typeof include.association is "string"
          throw new Error "Scope::includes - Value of key 'association' has to be a string"

        if @context.hasAssociation(include.association)
          field = include.association
          saladModel = @context.getAssociation(include.association)
          model = saladModel.daoInstance

      if include.includes
        # the included model requests other models to be included
        includes = includes.concat @_includeNestedIncludes(saladModel,include.includes)

      unless field
        throw new Error "Scope::includes - Could not find an association between #{@context.name} and #{model}"

      option =
        model: model
        as: field

      if includes.length isnt 0
        option.includes = includes

      @data.includes.push option

    @

  _includeNestedIncludes: (model,nestedIncludes) ->
    nestedScopes = []
    for nestedInclude in nestedIncludes
      nestedScope = model.includes([nestedInclude])
      nestedScopes = nestedScopes.concat nestedScope.data.includes

    nestedScopes

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

    if options.order
      options.order = []

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

    model.set key, null for key in keys

    model.save callback
