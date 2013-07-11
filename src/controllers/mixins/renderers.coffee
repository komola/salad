module.exports =
  InstanceMethods:
    respondWith: (formats) ->
      format = @params.format or "html"
      format = "html" unless formats[format]

      formats[format].apply @

    render: (options) ->
      unless typeof(options) is "object"
        options =
          status: 200

      # Render JSON response
      if options.json
        return @json options.json

      @html options

    html: (data) ->
      @response.send "Rendering HTML"

    json: (data) ->
      @response.send data