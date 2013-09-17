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
        @set key, val

    getAttributes: ->
      @attributeValues or= {}
      @attributeValues

    getAttributeDefinitions: ->
      @metadata().attributes

    set: (key, value) ->
      @_checkIfKeyExists key
      @attributeValues or= {}
      @attributeValues[key] = value

    get: (key) ->
      @_checkIfKeyExists key
      @attributeValues or= {}
      @attributeValues[key]

    _checkIfKeyExists: (key) ->
      unless key of @metadata().attributes
        throw new Error "#{key} not existent in #{@}"

