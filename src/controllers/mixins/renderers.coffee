handlebars = require "handlebars"
fs = require "fs"

handlebars.registerHelper "assets", ->
  assets = [
    "/assets/application.js"
  ]

  if Salad.env isnt "production"
    assets = Salad.Bootstrap.metadata().assets

    assets = assets.map (e) ->
      e = e.replace(Salad.root, "").replace(".coffee", ".js").replace("/app", "").replace(/\/(shared|client)/, "")

      "/javascripts#{e}"

  links = []
  for asset in assets
    links.push '<script src="'+asset+'" type="text/javascript"></script>'

  links.join "\n"

registeredPartials = false

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

    # method to render the actual layout
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

    # send the JSON response to the client and set correct content-type headers
    json: (data) ->
      @response.set "Content-Type", "application/json; charset=utf-8"
      @response.send data

    # render a handlebars template. Used by @html
    _renderHandlebars: (template) ->
      @_registerPartials()

      template += ".hbs"

      unless template of Salad.Bootstrap.metadata().templates
        throw new Error "Template #{template}.hbs does not exist!"

      templateContent = Salad.Bootstrap.metadata().templates[template]

      template = handlebars.compile templateContent

      return template

    # registers all partials that were found during Salad.Bootstraps bootstrapping.
    # partials have to start with an underscore in their name: controller/_partial.hbs
    _registerPartials: ->
      return if registeredPartials

      registeredPartials = true

      for file, content of Salad.Bootstrap.metadata().templates
        fileParts = file.split "/"

        if fileParts[1].substr(0, 1) is "_"
          file = file.replace ".hbs", ""
          handlebars.registerPartial file, content
