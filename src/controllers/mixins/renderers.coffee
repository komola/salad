handlebars = require "handlebars"
fs = require "fs"

handlebars.registerHelper "debug", (optionalValue) ->
  console.log "\nCurrent Context"
  console.log "===================="
  console.log @

  if  arguments.length > 1
    console.log "Value"
    console.log "===================="
    console.log optionalValue

handlebars.registerHelper "stylesheets", (type) ->
  assets = require "#{Salad.root}/app/config/server/assets"

  stylesheets = assets.stylesheets[type] or []
  files = []

  if Salad.env is "production"
    files.push "/assets/#{type}.css"

  else
    for stylesheet in stylesheets
      files.push "/stylesheets/#{stylesheet}.css"

  tags = []
  for stylesheet in files
    tags.push '<link href="'+stylesheet+'" rel="stylesheet">'

  new handlebars.SafeString(tags.join("\n"))

handlebars.registerHelper "javascripts", (type) ->
  assets = require "#{Salad.root}/app/config/server/assets"

  javascripts = assets.javascripts[type] or []
  files = []

  if Salad.env is "production"
    files.push "/assets/#{type}.js"

  else
    for javascript in javascripts
      files.push "/javascripts/#{javascript}.js"

  links = []
  for asset in files
    links.push '<script src="'+asset+'" type="text/javascript"></script>'

  new handlebars.SafeString(links.join("\n"))

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
      # don't render twice
      return if @isRendered

      @isRendered = true
      unless typeof(options) is "object"
        templateOptions = arguments[1] or {}

        options =
          template: options
          options: templateOptions

        if templateOptions.status
          options.status = templateOptions.status

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
        @json options.json

      else
        @html options

      @response.end()
      @emit "render"

    # method to render the actual layout
    html: (data) ->
      template = @_renderHandlebars data.template
      options =
        env: Salad.env
        request: @request

      # transform class representations of models to JSON data
      # otherwise handlebars can't handle them
      for key, val of data.options
        if val.toJSON
          data.options[key] = val.toJSON()

      data.options = _.extend options, data.options
      content = template(data.options)

      if data.layout
        layout = @_renderHandlebars "layouts/#{data.layout}"

        options.content = content

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
        throw new Error "Template #{template} does not exist!"

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
