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

    parentResource: ->
      relation = @findParentRelation()

      unless relation
        return false

      App[relation.resourceClass]

    findParent: (callback) ->
      parent = @parentResource()
      relation = @findParentRelation()

      unless parent
        return callback.call @, null, false if callback
        return false

      parent.find @params[relation.idParameter], (err, parent) =>
        @parent = parent
        return callback.call @, err, parent if callback

      false

    resourceClass: ->
      unless @resourceOptions?.resourceClass
        throw new Error "No resource registered!"

      return App[@resourceOptions.resourceClass]

    findResource: (callback) ->
      paramKey = @resourceOptions.idParameter
      @scoped (err, scope) =>
        scope.find @params[paramKey], (err, resource) =>
          if err
            return callback.apply @, [error]

          callback.apply @, [null, resource]

    scoped: (callback) ->
      @findParent (err, parent) =>
        if parent
          collectionGetter = "get#{_.capitalize(@resourceOptions.collectionName)}"
          scope = parent[collectionGetter]()

        else
          scope = @resourceClass()

        conditions = @buildConditionsFromParameters @params

        scope = @applyConditionsToScope scope, conditions

        callback.call @, null, scope

    ###
      This builds conditions by URL params. Possible condtions are:
        Where:
          Equality:
            ?title=Dishes
          Greater than:
            ?createdAt=>2013-07-15T09:09:09.000Z
          Less than:
            ?createdAt=<2013-07-15T09:09:09.000Z
        Sorting:
          ?sort=createdAt,-title

          This would sort ascending by createdAt and descending by title. Ascending is assumed by default
    ###
    buildConditionsFromParameters: (parameters) ->

      ###
          Some parameter names are reserved and have a special meaning
      ###
      reservedParams = ["sort","include","includes","limit","offset","method","controller","action","format"]

      # only accept parameters that represent an attribute for where conditions
      allowedWhereAttributes = []
      allowedWhereAttributes.push key for key,value of App[@resourceOptions.resourceClass].metadata().attributes

      conditions = {}

      for key,value of parameters
        # check if the parameter name needs special handling
        if key in reservedParams
          if key is "sort"
            # sorting supports multiple attributes to sort by
            sortParams = value.split(",")

            for value in sortParams
              firstChar = value[0]
              # we sort ascending by default
              # a minus in front of the attribute sorts descending
              if firstChar isnt "-"
                unless conditions.asc?
                  conditions.asc = []
                conditions.asc.push value
              else if firstChar is "-"
                unless conditions.desc?
                    conditions.desc = []
                conditions.desc.push value[1..-1]

          if key is "limit" or key is "offset"
            # limit and offset are simple params
            conditions[key] = value

          if key is "includes"
            # includes can contain multiple classes
            includeParams = value.split(",")
            for value in includeParams
              unless conditions.includes?
                  conditions.includes = []
              conditions.includes.push value
          continue
        if key not in allowedWhereAttributes
          continue
        # all other parameter names are treated as where conditions
        unless conditions.where?
          conditions.where = {}
        firstChar = value[0]
        checksForEquality = firstChar isnt ">" and firstChar isnt "<"
        if not checksForEquality
          if firstChar is ">"
            # we search values which are greater as the specified value
            bindingElm = "gt"
          else
            bindingElm = "lt"

          conditions.where[key] = {}
          conditions.where[key][bindingElm] = value[1..-1]
        else
          conditions.where[key] = value

      conditions

    applyConditionsToScope: (scope, conditions) ->
      # some conditions do not need special handling
      simpleKeys = ["limit","offset","where"]

      for key,value of conditions
        # iterate by key over the conditions object
        if key not in simpleKeys
          # includes, asc and desc need special handling

          # includes takes an array as parameter
          includesClassArray = []

          for value in conditions[key]
            if key is "includes"

              # the param is a string, from which we need to construct the class name
              theClass = App[value]
              includesClassArray.push theClass
              scope = scope.includes includesClassArray

            if key is "asc"
              scope = scope.asc value

            if key is "desc"
              scope = scope.desc value
        else
          # apply calls the method key on the object scope with the values given in the array
          scope = scope[key].apply(scope,[value])

      # return the scope, so it can be used
      scope
