handlebars = require "handlebars"
fs = require "fs"

module.exports =
  ClassMethods:
    layout: (name) ->
      @metadata().layout = name

  InstanceMethods:
    respondWith: (formats) ->
      format = @params.format or "html"
      format = "html" unless formats[format]

      formats[format].apply @

    render: (options) ->
      unless typeof(options) is "object"
        templateOptions = arguments[1] or {}

        options =
          template: options
          options: templateOptions

        if templateOptions.layout isnt undefined
          options.layout = templateOptions.layout
          delete options.options.layout

      defaultOptions =
        status: 200
        layout: @metadata().layout

      options = _.extend defaultOptions, options

      @response.status options.status

      # Render JSON response
      if options.json
        return @json options.json

      @html options

    html: (data) ->
      template = @_renderHandlebars data.template
      options =
        env: Salad.env

      data.options = _.extend options, data.options
      content = template(data.options)

      if data.layout
        layout = @_renderHandlebars "layouts/#{data.layout}"

        options =
          content: content
          env: Salad.env

        content = layout options

      @response.send content

    _renderHandlebars: (template) ->
      if fs.existsSync Salad.root+"/app/templates/shared/#{template}.hbs"
        template = Salad.root+"/app/templates/shared/#{template}.hbs"
      else if fs.existsSync Salad.root+"/app/templates/server/#{template}.hbs"
        template = Salad.root+"/app/templates/server/#{template}.hbs"
      else
        throw new Error "Template #{template}.hbs does not exist!"

      templateContent = fs.readFileSync(template).toString()

      template = handlebars.compile templateContent

      return template

    json: (data) ->
      @response.set "Content-Type", "application/json; charset=utf-8"
      @response.send data