handlebars = require "handlebars"

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

class Salad.Template.Handlebars
  registeredPartials: false

  @render: (template, options) ->
    @_registerPartials()

    template = @compile template
    renderedTemplate = template options

    renderedTemplate

  @compile: (template) ->
    template = "#{template}.hbs"

    unless template of Salad.Bootstrap.metadata().templates
      throw new Error "Template #{template} does not exist!"

    templateContent = Salad.Bootstrap.metadata().templates[template]

    template = handlebars.compile templateContent

    return template

  # registers all partials that were found during Salad.Bootstraps bootstrapping.
  # partials have to start with an underscore in their name: controller/_partial.hbs
  @_registerPartials: ->
    return if @registeredPartials

    @registeredPartials = true

    for file, content of Salad.Bootstrap.metadata().templates
      fileParts = file.split "/"

      if fileParts[1].substr(0, 1) is "_"
        file = file.replace ".hbs", ""
        handlebars.registerPartial file, content
