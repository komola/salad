unless window?
  validator = require "validator"
  {check, sanitize} = validator

else
  {check, sanitize} = window
  window.Salad = Salad? or {}

class Salad.Validator
  @check: (attributes, checks) ->
    errors = false

    for field, validators of checks
      if not attributes[field] and
        not validators.notEmpty and
        not validators.notNull

          continue

      for validator, options of validators
        try
          fieldCheck = undefined
          passedOptions = _.clone options

          # custom error message
          if _.isString(options) or options.message
            message = if _.isString options then options else options.message

            fieldCheck = check(attributes[field], message)

          else
            fieldCheck = check(attributes[field])

          if options.options
            passedOptions = options.options

          fieldCheck[validator] passedOptions
        catch e
          errors or= {}
          errors[field] or= []
          errors[field].push e.message

    result = if errors then errors else true

    return result
