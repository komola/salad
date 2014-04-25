async = require "async"

class Salad.Model extends Salad.Base
  @mixin require "../mixins/metadata"
  @mixin require "../mixins/triggers"
  @mixin require "./mixins/attributes"
  @mixin require "./mixins/changes"
  @mixin require "./mixins/associations"
  @mixin require "./mixins/scope"
  @mixin require "./mixins/validation"

  @before "save", "validate"
  @after "save", "takeSnapshot"

  daoInstance: undefined
  eagerlyLoadedAssociations: {}
  isNew: true
  triggerStack: {}

  constructor: (attributes, options) ->
    # overwrite default options with passed options
    options = _.extend {isNew: true}, options

    @eagerlyLoadedAssociations = options.eagerlyLoadedAssociations or {}
    @isNew = options.isNew

    @setAttributes attributes

    unless @isNew
      @takeSnapshot()

    unless options.daoInstance
      throw new Error "No DAO instance set!"

    @daoInstance = options.daoInstance

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
    resource = @build attributes

    async.series [
      (cb) => resource.runTriggers "before:create", cb
      (cb) => resource.save (_err, _res) =>
        err = _err
        resource = _res

        cb err
      (cb) => resource.runTriggers "after:create", cb
    ], =>
      callback err, resource

  updateAttributes: (attributes, callback) ->
    @setAttributes attributes

    @save callback

  save: (callback) =>
    resource = null

    action = (cb) =>
      if @isNew
        return @daoInstance.create @getAttributes(), (_err, _res) =>
          resource = _res
          cb _err

      changedAttributes = _.keys @getChangedAttributes()
      delta = _.pick @getAttributes(), changedAttributes

      @daoInstance.update @, delta, (_err, _res) =>
        resource = _res
        cb _err

    async.series [
        (cb) => @runTriggers "before:save", (err) =>
          cb err
        (cb) => @verifyAssociationsExist cb
        action
        (cb) =>
          @isNew = false
          @set "id", resource.get("id")
          cb()
        (cb) => @runTriggers "after:save", cb
      ],

      (err) =>
        if callback
          callback err, resource

  ###
  Helper function that is called when calling save.
  It verifies that all the associations actually exist before writing to the
  database.

  Calls the callback with an error if an invalid association was found.
  ###
  verifyAssociationsExist: (callback) =>
    associations = @metadata().associations
    attributes = @getAttributes()

    checkForeignKey = (name, cb) =>
      {foreignKey} = associations[name]

      # only check for models that "own" the association and that contain the
      # foreignKey attribute
      return cb() unless associations[name].isOwning

      value = attributes[foreignKey]

      # skip the check if there is no value provided for this field
      return cb() unless value

      modelClass = associations[name].model

      modelClass.where(id: value).count (err, count) =>
        return cb err if err
        return cb() if count > 0

        error = new Error("Invalid value for #{foreignKey}. No resource found with ID #{value}")
        error.isValid = false
        return cb error

    async.eachSeries _.keys(associations), checkForeignKey, callback

  ###
  Increment the field or fields of a model

  Usage:
    # Increment a field by 1:
    model.increment "counter", (err, res) =>
      console.log model.get("counter") is res.get("counter") # => true

    # Increment by a specific value:
    model.increment "counter", 3, (err, res) =>
      console.log model.get("counter") is res.get("counter") # => true

    # Increment multiple fields:
    model.increment counter: 1, counterB: 3, (err, res) =>
      console.log model.get("counter") is res.get("counter") # => true
      console.log model.get("counterB") is res.get("counterB") # => true
  ###
  increment: (field, value, callback) =>
    if typeof value is "function"
      callback = value
      value = 1

    @daoInstance.increment @, field, value, (err, model) =>
      return callback err if err

      if typeof field isnt "object"
        key = field
        field = {}
        field[key] = model.get key

      for key, val of field
        @set key, model.get(key)

      callback err, model

  ###
  Decrement the field of a model.

  See @increment for usage options
  ###
  decrement: (field, value, callback) =>
    if typeof value is "function"
      callback = value
      value = 1

    @daoInstance.decrement @, field, value, (err, model) =>
      return callback err if err

      if typeof field isnt "object"
        key = field
        field = {}
        field[key] = model.get key

      for key, val of field
        @set key, model.get(key)

      callback err, model

  destroy: (callback) ->
    @daoInstance.destroy @, callback

  ## Misc stuff #########################################
  toJSON: ->
    associations = @getAssociations()

    for key of associations
      if associations[key] instanceof Array
        associations[key] = (model.toJSON() for model in associations[key])

      else
        associations[key] = associations[key].toJSON()

    attributes = _.extend @getAttributes(), associations

    attributes

  toString: ->
    @constructor.name

  # Helpful method
  # This is called when console.log modelInstance is called
  inspect: ->
    attributes = @toJSON()
    methods = _.keys @

    data =
      attributes: attributes
      methods: methods
