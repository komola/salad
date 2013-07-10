module.exports =
  ClassMethods:
    resource: (options) ->
      @resourceOptions or= {}

      unless options
        throw new Error "@resource() can not be called without options!"

      if typeof(options) is "string"
        options =
          name: options

      klass = _.capitalize options.name

      defaultOptions =
        name: options.name
        resourceClass: klass
        collectionName: _.pluralize options.name
        idParameter: options.name+"Id"

      options = _.extend defaultOptions, options

      @resourceOptions = options

    belongsTo: (options) ->
      @parentResourceOptions or= []

      unless options
        unless @parentResourceOptions.resourceClass
          throw new Error "No resource registered!"

        return App[@parentResourceOptions.resourceClass]

      if typeof(options) is "string"
        options =
          name: options

      klass = _.capitalize options.name

      defaultOptions =
        name: options.name
        resourceClass: klass
        idParameter: options.name+"Id"

      options = _.extend defaultOptions, options

      @parentResourceOptions.push options


  InstanceMethods:
    findParentRelation: ->
      belongsTo = @constructor.parentResourceOptions
      params = @params

      unless belongsTo?.length > 0
        return null

      for relation in belongsTo
        if params.hasOwnProperty relation.idParameter
          return relation

      return null

    findParent: (callback) ->
      relation = @findParentRelation()

      unless relation
        return callback.call @, null, false if callback
        return false

      parent = App[relation.resourceClass]

      parent.find @params[relation.idParameter], (err, parent) =>
        return callback.call @, err, parent if callback

      false


    resource: ->
      unless @resourceOptions?.resourceClass
        throw new Error "No resource registered!"

      return App[@resourceOptions.resourceClass]

    findResource: (callback) ->
      paramKey = @resourceOptions.idParameter
      @resource().find @params[paramKey], (err, resource) =>
        if err
          return callback.apply @, [error]

        callback.apply @, [null, resource]

    scoped: (callback) ->
      @findParent (err, parent) =>
        if parent
          collectionGetter = "get#{_.capitalize(@resourceOptions.collectionName)}"
          scope = parent[collectionGetter]()

          callback.call @, null, scope

        else
          scope = @resource()
          callback.call @, null, scope