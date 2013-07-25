async = require "async"

class Salad.Model extends Salad.Base
  @mixin require "../mixins/metadata"
  @mixin require "./mixins/triggers"
  @mixin require "./mixins/attributes"

  daoInstance: undefined
  eagerlyLoadedAssociations: {}
  associations: {}
  isNew: true
  triggerStack: {}

  constructor: (attributes, options) ->
    # pass the attributes from the static method on to our model
    # @metadata.attributes = _.clone @metadata().attributes

    @setAttributes attributes

    # overwrite default options with passed options
    options = _.extend {isNew: true}, options

    @isNew = options.isNew

    @eagerlyLoadedAssociations = options.eagerlyLoadedAssociations

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

          cb()
        (cb) => resource.runTriggers "after:create", cb
      ],

      =>
        callback err, resource

  updateAttributes: (attributes, callback) ->
    @setAttributes attributes

    @save callback

  save: (callback) =>
    err = null
    resource = null

    action = (cb) =>
      if @isNew
        return @daoInstance.create @getAttributes(), (_err, _res) =>
          err = _err
          resource = _res
          cb()

      @daoInstance.update @, @getAttributes(), (_err, _res) =>
        err = _err
        resource = _res
        cb()

    async.series [
        (cb) => @runTriggers "before:save", cb
        action
        (cb) => resource.runTriggers "after:save", cb
      ],

      =>
        callback err, resource

  destroy: (callback) ->
    callback()


  ## Data retrieval #####################################
  ## These are pretty much just proxy methods that insantiate a scope and pass the
  ## parameters on to the scope

  @where: (attributes) ->
    @scope().where attributes

  @limit: (limit) ->
    @scope().limit limit

  @offset: (offset) ->
    @scope().offset offset

  @asc: (field) ->
    @scope().asc field

  @desc: (field) ->
    @scope().desc field

  @contains: (field, value) ->
    @scope().contains field, value

  @include: (models) ->
    @scope().include models

  @all: (callback) ->
    @scope().all callback

  @first: (callback) ->
    @scope().first callback

  @count: (callback) ->
    @scope().count callback

  @find: (id, callback) ->
    @scope().find id, callback

  @findAndCountAll: (callback) ->
    @scope().findAndCountAll callback

  ## Associations ##########################################
  # register a hasMany association for this mdoel
  @hasMany: (targetModel, options) ->
    # this is the method that we will create in this model
    getterName = "get#{options.as}"

    # this is the foreignKey field
    foreignKey = options.foreignKey

    # register the association
    @_registerAssociation options.as, targetModel

    # register attribute in targetModel
    targetModel.attribute foreignKey

    # register the method in this model
    # Don't bind to this context, because we want the method to be run in the
    # context of the instance
    @::[getterName] = ->
      conditions = {}
      conditions[foreignKey] = @get "id"

      scope = targetModel.scope()

      scope.where(conditions)

  # register a reverse-association in this model
  @belongsTo: (targetModel, options) ->
    # this is the method that we will create in this model
    getterName = "get#{options.as}"

    foreignKey = options.foreignKey

    # register the association
    @_registerAssociation options.as, targetModel

    # @attributes[foreignKey] = undefined
    @attribute foreignKey

    # register the method in this model.
    # Don't bind to this context, because we want the method to be run in the
    # context of the instance
    @::[getterName] = ->
      conditions =
        id: @get foreignKey

      scope = targetModel.scope()

      scope.where(conditions)

  @_registerAssociation: (key, model) ->
    key = key.toLowerCase()
    @::associations[key] = model

  ## Trigger methods ###################################

  ## Misc stuff #########################################

  # Builds a new scope with the current dao instance as context
  @scope: ->
    return new Salad.Scope @

  toJSON: ->
    associations = @getAssociations()

    for key of associations
      if associations[key] instanceof Array
        associations[key] = (model.toJSON() for model in associations[key])

      else
        associations[key] = associations[key].toJSON()

    attributes = _.extend @getAttributes(), associations

    attributes

  getAssociations: ->
    _.clone @eagerlyLoadedAssociations

  toString: ->
    @.constructor.name