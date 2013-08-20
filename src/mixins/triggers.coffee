module.exports =
  InstanceMethods:
    # resolve this method call to the static method, but pass the current context
    # this way we can reuse the static runTriggers method and don't have to
    # copy it here
    runTriggers: (action, callback) ->
      @constructor.runTriggers.apply @, [action, callback]

  ClassMethods:
    before: (method, action) ->
      method = "before:#{method}"
      @_registerTrigger method, action

    after: (method, action) ->
      method = "after:#{method}"
      @_registerTrigger method, action

    _registerTrigger: (method, action) ->
      @metadata().triggerStack or= {}

      stack = @metadata().triggerStack

      @metadata().triggerStack[method] or= []
      @metadata().triggerStack[method].push action

    runTriggers: (action, callback) ->
      @metadata().triggerStack or= {}
      stack = @metadata().triggerStack[action] or []

      iterator = (action, cb) =>
        # resolve action if only a string is passed
        if typeof action is "string"
          action = @[action]

        # does the method accept a callback parameter?
        if action.length > 0
          action.call @, cb

        # if not it is no async method -> call cb() to keep going
        else
          action.call @
          cb()

      async.eachSeries stack, iterator, callback
