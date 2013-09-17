module.exports =
  InstanceMethods:
    validate: (done) ->
      result = @isValid @getAttributes()
      errors = null

      if result isnt true
        errors =
          isValid: false
          errors: result

      done errors

    # Check if the passed attributes are valid
    #
    # This method should return true if the data is valid.
    #
    # Otherwise it should return an object containing detailed errors
    # for each field.
    isValid: (attributes) -> true

