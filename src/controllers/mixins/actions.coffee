module.exports =
  InstanceMethods:
    index: ->
      @_index (error, resources) =>
        @respond
          html: -> @response.send "Ich habe #{resources.length} Einträge"
          json: -> @response.send resources

    _index: (callback) ->
      @scoped (err, scope) =>
        scope.all (err, resources) =>
          callback.apply @, [null, resources]

    show: ->
      @_show (err, resource) =>
        @respond
          html: -> @response.send "Name: #{resource.get("name")}"
          json: -> @response.send resource

    _show: (callback) ->
      @findResource (err, resource) =>
        unless resource
          return @_notFoundHandler()

        callback.apply @, [err, resource]

    create: ->
      @_create (error, resource) =>
        @respond
          html: -> @response.send "Created!"
          json: -> @response.send resource

    _create: (callback) ->
      data = @params[@resourceOptions.resourceName]

      @resource().create data, (err, resource) =>
        if err
          return callback.apply @, [err, null]

        @response.status 201
        callback.apply @, [null, resource]

    update: ->
      @_update (err, resource) =>
        @respond
          html: -> @response.send "Yo success"
          json: -> @response.send resource

    _update: (callback) ->
      @findResource (err, resource) =>
        unless resource
         return @_notFoundHandler()

        data = @params[@resourceOptions.resourceName]

        resource.updateAttributes data, (err, resource) =>
          if err
            return callback.apply @, [err]

          callback.apply @, [err, resource]

    destroy: ->
      @_destroy (err, resource) =>
        resource.destroy (err) =>
          @respond
            html: -> @response.send "Deleted"
            json: -> @response.send resource

    _destroy: (callback) ->
      @findResource (err, resource) =>
        unless resource
         return @_notFoundHandler()

        callback.apply @, [err, resource]

