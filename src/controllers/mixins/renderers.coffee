handlebars = require "handlebars"
fs = require "fs"

module.exports =
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

      defaultOptions =
        status: 200

      options = _.extend defaultOptions, options

      @response.status options.status

      # Render JSON response
      if options.json
        return @json options.json

      @html options

    html: (data) ->
      template = @_renderHandlebars data.template


      @response.send template(data.options)

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
      @response.send data