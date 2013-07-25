module.exports =
  ClassMethods:
    attribute: (name, type) ->
      @metadata().attributes or= {}

      type or= "String"

      @metadata().attributes[name] = null

  InstanceMethods:

    setAttributes: (attributes) ->
      for key, val of attributes
        @set key, val

    getAttributes: ->
      @attributeValues or= {}
      @attributeValues

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

