async = require "async"

class Salad.Model extends Salad.Base
  @mixin require "../mixins/metadata"
  @mixin require "./mixins/triggers"
  @mixin require "./mixins/attributes"
  @mixin require "./mixins/associations"
  @mixin require "./mixins/scope"

  daoInstance: undefined
  eagerlyLoadedAssociations: {}
  isNew: true
  triggerStack: {}

  constructor: (attributes, options) ->
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