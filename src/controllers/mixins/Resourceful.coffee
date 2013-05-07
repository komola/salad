Salad.ResourcefulController =
  scoped: (callback) ->
    scope = @resource
    callback.call @, null, scope.where(@criteria())