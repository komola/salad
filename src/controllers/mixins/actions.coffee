module.exports =
  InstanceMethods:
    index: ->
      @_index (error, resources) =>
        @respondWith
          html: -> "Ich habe #{resources.length} Einträge"
          json: -> @render json: resources

    _index: (callback) ->
      @scoped (err, scope) =>
        scope.all (err, resources) =>
          callback.apply @, [null, resources]

    show: ->
      @_show (err, resource) =>
        @respondWith
          html: -> "Name: #{resource.get("name")}"
          json: -> @render json: resource

    _show: (callback) ->
      @findResource (err, resource) =>
        unless resource
          return @_notFoundHandler()

        callback.apply @, [err, resource]

    create: ->
      @_create (error, resource) =>
        @respondWith
          html: -> "Created!"
          json: -> @render json: resource, status: 201

    _create: (callback) ->
      data = @params[@resourceOptions.name]

      @scoped (err, scope) =>
        scope.create data, (err, resource) =>
          if err
            return callback.apply @, [err, null]

          callback.apply @, [null, resource]

    update: ->
      @_update (err, resource) =>
        @respondWith
          html: -> "Yo success"
          json: -> @render json: resource

    _update: (callback) ->
      @findResource (err, resource) =>
        unless resource
         return @_notFoundHandler()

        data = @params[@resourceOptions.name]
        resource.updateAttributes data, (err, resource) =>
          if err
            return callback.apply @, [err]

          callback.apply @, [err, resource]

    destroy: ->
      @_destroy (err, resource) =>
        resource.destroy (err) =>
          @respondWith
            html: -> "Deleted"
            json: -> @render json: resource

    _destroy: (callback) ->
      @findResource (err, resource) =>
        unless resource
         return @_notFoundHandler()

        callback.apply @, [err, resource]

    _notFoundHandler: ->
      @respondWith
        html: => "Not found"
        json: => @render json: {}, status: 404