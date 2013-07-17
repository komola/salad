module.exports =
  InstanceMethods:
    respondWith: (formats) ->
      format = @params.format or "html"
      format = "html" unless formats[format]

      formats[format].apply @

    render: (options) ->
      unless typeof(options) is "object"
        options =
          template: ""

      defaultOptions =
        status: 200

      options = _.extend defaultOptions, options

      @response.status options.status

      # Render JSON response
      if options.json
        return @json options.json

      @html options

    html: (data) ->
      @response.send "Rendering HTML"

    json: (data) ->
      @response.set "Content-Type", "application/json; charset=utf-8"
      @response.send data