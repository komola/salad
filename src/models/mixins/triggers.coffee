module.exports =
  InstanceMethods:
    runTriggers: (action, callback) ->
      @metadata().triggerStack or= {}
      stack = @metadata().triggerStack[action] or []

      iterator = (action, cb) =>
        action.call @, cb

      async.eachSeries stack, iterator, callback


  ClassMethods:
    before: (method, action) ->
      method = "before:#{method}"
      @_registerTrigger method, action

    after: (method, action) ->
      method = "after:#{method}"
      @_registerTrigger method, action

    _registerTrigger: (method, action) ->
      @metadata().triggerStack or= {}

      @metadata().triggerStack[method] or= []
      @metadata().triggerStack[method].push action

    runTriggers: (action, callback) ->
      @metadata().triggerStack or= {}
      stack = @metadata().triggerStack[action] or []

      iterator = (action, cb) =>
        action.call @, cb

      async.eachSeries stack, iterator, callback


