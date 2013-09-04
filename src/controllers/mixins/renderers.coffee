module.exports =
  ClassMethods:
    # set the default layout for this controller
    layout: (name) ->
      @metadata().layout = name

  InstanceMethods:
    # use this to offer different response formats in your controller.
    # example:
    ###
    index: ->
      @_index (error, resources) =>
        @respondWith
          html: -> "Ich habe #{resources.length} Einträge"
          json: -> @render json: resources

    ###
    respondWith: (formats) ->
      format = @params.format or "html"
      format = "html" unless formats[format]

      formats[format].apply @

    ###
    use this to send a response to the current request

    possible use cases:

    render json:
    @render json: data: [{id: 1}]

    render html template:
    @render "controller/action", collection: @collection

    render html template without layout:
    @render "controller/action", collection: @collection, layout: false

    render html template and don't use the default layout of the controller:
    @render "controller/action", collection: @collection, layout: "nice"

    render custom status code:
    @render "errors/notfound", status: 404
    ###
    render: (options) ->
      # don't render twice
      return if @isRendered
      @isRendered = true

      # render template: @render "foo/bar", model: @resource
      unless typeof(options) is "object"
        templateOptions = arguments[1] or {}

        options =
          template: options
          data: templateOptions

        if templateOptions.status
          options.status = templateOptions.status

        if templateOptions.layout isnt undefined
          options.layout = templateOptions.layout
          delete templateOptions.layout

      defaultOptions =
        status: 200
        layout: @metadata().layout
        data: undefined

      options = _.extend defaultOptions, options

      @response.status options.status

      # Render JSON response
      if options.json
        @json options.json

      else
        @html options

      @emit "render"

    # method to render the actual layout
    html: (options) ->
      defaultOptions =
        env: Salad.env
        request: @request

      options = _.extend defaultOptions, options
      options.data.layout = options.layout

      content = Salad.Template.render options.template, options.data

      @response.send content

    # send the JSON response to the client and set correct content-type headers
    json: (data) ->
      @response.set "Content-Type", "application/json; charset=utf-8"
      @response.send data
