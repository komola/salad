class Salad.RestfulController extends Salad.Controller
  resourceName: ""

  constructor: ->
    name = _s.capitalize @resourceName
    @resource = App[name]

  index: ->
    @_index (error, resources) =>
      @respond
        html: -> @response.send "Ich habe #{resources.length} Einträge"
        json: -> @response.send resources

  _index: (callback) ->
    @resource.findAll().success (resources) =>
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
    data = @params[@resourceName]

    @resource.create(data)
      .success (resource) =>
        @response.status 201

        callback.apply @, [null, resource]

      .error (error) =>
        callback.apply @, [error, null]

  update: ->
    @_update (err, resource) =>
      @respond
        html: -> @response.send "Yo success"
        json: -> @response.send resource

  _update: (callback) ->
    @findResource (err, resource) =>
      unless resource
       return @_notFoundHandler()

      data = @params[@resourceName]

      resource.updateAttributes(data)
        .success =>
          callback.apply @, [err, resource]

        .error (error) =>
          callback.apply @, [err]

  destroy: ->
    @_destroy (err, resource) =>
      resource.destroy()
        .success =>
          @respond
            html: -> @response.send "Deleted"
            json: -> @response.send resource

  _destroy: (callback) ->
    @findResource (err, resource) =>
      unless resource
       return @_notFoundHandler()

      callback.apply @, [err, resource]

  findResource: (callback) ->
    @resource.find(@params.id)
      .success (resource) =>
        callback.apply @, [null, resource]

      .error (error) =>
        callback.apply @, [error]

  _notFoundHandler: ->
    @response.status 404

    return @respond
      html: -> @response.send "Not found"
      json: -> @response.send status: 404
