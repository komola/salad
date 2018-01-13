module.exports =
  ClassMethods:
    # Add an attribute to this model
    #
    # Possible calls:
    #
    # @attribute "firstname"
    #
    # # Setting the type
    # @attribute "firstname", type: "String"
    attribute: (name, options) ->
      @metadata().attributes or= {}

      defaultOptions =
        name: name
        type: "String"

      options = _.extend defaultOptions, options

      @metadata().attributes[name] = options

  InstanceMethods:
    setAttributes: (attributes) ->
      for key, val of attributes
        if @hasAttribute key
          @set key, val

        else if @hasAssociation key
          @setAssociation key, val

    getDefaultValues: ->
      defaultValues = {}
      for key, options of @getAttributeDefinitions() when options.default isnt undefined
        defaultValues[key] = options.default

      defaultValues

    # initialize default values
    initDefaultValues: ->
      return if @attributeValues

      @attributeValues = @getDefaultValues()

      # do not register the default values as changes
      @takeSnapshot()

    # check if a model has an attribute
    hasAttribute: (key) ->
      @metadata().attributes[key]?

    getAttributes: ->
      @initDefaultValues()

      return _.clone @attributeValues, true

    getAttributeDefinitions: ->
      @metadata().attributes

    set: (key, value) ->
      @_checkIfKeyExists key
      @initDefaultValues()
      @attributeValues[key] = value

    get: (key) ->
      @_checkIfKeyExists key
      @initDefaultValues()
      value = @attributeValues[key]

      if value is undefined
        value = @getAttributeDefinitions()[key]?.defaultValue

      value

    _checkIfKeyExists: (key) ->
      unless key of @metadata().attributes
        throw new Error "#{key} not existent in #{@}"

