module.exports =
  InstanceMethods:
    validate: (done) ->
      result = @isValid @getAttributes()
      error = null

      if result isnt true
        error = new Error "ValidationError"
        error.isValid = false
        error.errors = result

      done error

    # Check if the passed attributes are valid
    #
    # This method should return true if the data is valid.
    #
    # Otherwise it should return an object containing detailed errors
    # for each field.
    isValid: (attributes) -> true

