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

class Salad.Model
  daoInstance: undefined
  attributes: {}
  isNew: true

  constructor: (attributes, options) ->
    @setAttributes attributes

    # overwrite default options with passed options
    options = _.extend {isNew: true}, options

    @isNew = options.isNew

    unless options.daoInstance
      throw new Error "No DAO instance set!"

    @daoInstance = options.daoInstance

  setAttributes: (attributes) ->
    for key, val of attributes
      @attributes[key] = val


  ## DAO functionality #################################
  @dao: (options) ->
    @daoInstance = new Salad.DAO.Sequelize options.instance, @

  @build: (attributes) ->
    unless @daoInstance
      return throw new Error "No DAO object is set!"

    options =
      daoInstance: @daoInstance

    resource = new @(attributes, options)

    resource

  @create: (attributes, callback) ->
    unless @daoInstance
      return throw new Error "No DAO object is set!"

    err = undefined
    resource = undefined

    calls = [
      # (cb) => @runTriggers "before:create", cb
      # (cb) => @runTriggers "before:save", cb
      (cb) => @daoInstance.create attributes, (_err, _res) =>
        err = _err
        resource = _res

        cb()
      # (cb) => @runTriggers "after:save", cb
      # (cb) => @runTriggers "after:create", cb
    ]

    async.series calls, =>
      callback err, resource

  updateAttributes: (attributes, callback) ->
    @setAttributes attributes

    @save callback

  save: (callback) =>
    if @isNew
      return @daoInstance.create @attributes, callback

    @daoInstance.update @, @attributes, callback

  destroy: (callback) ->
    callback()


  ## Data retrieval #####################################
  ## These are pretty much just proxy methods that insantiate a scope and pass the
  ## parameters on to the scope

  @where: ->
    @scope().where.apply @, arguments

  @limit: ->
    @scope().limit.apply @, arguments

  @asc: ->
    @scope().asc.apply @, arguments

  @desc: ->
    @scope().desc.apply @, arguments

  @all: ->
    @scope().all.apply @, arguments

  @first: ->
    @scope().first.apply @, arguments

  @find: (id, callback) ->
    @scope().where(id: id).first callback

  ## Trigger methods ###################################

  @before: (method, action) ->
    method = "before:#{method}"
    @triggerStack[method] or= []

    @triggerStack[methood].push action

  runTriggers: (action, callback) =>
    stack = @triggerStack[action] or []

    async.series stack, callback

  ## Misc stuff #########################################

  # Builds a new scope with the current dao instance as context
  @scope: ->
    return new Salad.Scope @daoInstance

  toJSON: ->
    @attributes

