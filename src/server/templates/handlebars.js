handlebars = require "handlebars"

class Salad.Template.Handlebars
  registeredPartials: false

  # render a template, passing the options to the template and returning an
  # html string
  @render: (template, options) ->
    @_registerPartials()

    template = @compile template
    renderedTemplate = template options

    renderedTemplate

  # compile a handlebars template into a function that can get called
  # to render the content
  @compile: (template) ->
    template = "#{template}.hbs"

    unless template of Salad.Bootstrap.metadata().templates
      throw new Error "Template #{template} does not exist!"

    templateContent = Salad.Bootstrap.metadata().templates[template]
    template = handlebars.compile templateContent

    return template

  # register a single partial
  @registerPartial: (file, content) ->
    fileParts = file.split "/"

    # partials start with an underscore in their name
    return unless fileParts[1]?.substr(0, 1) is "_"

    file = file.replace ".hbs", ""
    handlebars.registerPartial file, content

  # registers all partials that were found during Salad.Bootstraps bootstrapping.
  # partials have to start with an underscore in their name: controller/_partial.hbs
  @_registerPartials: ->
    return if @registeredPartials

    @registeredPartials = true

    for file, content of Salad.Bootstrap.metadata().templates
      @registerPartial file, content
