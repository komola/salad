class Salad.Template
  ###
  Render a template

  Mostly used in Salads Controllers and Mailers.

  Usage:
    Salad.Template.render "user/show", user: userModel

    # with layout:
    Salad.Template.render "user/show", user: userModel, layout: "application"
  ###
  @render: (file, options) ->
    defaultOptions =
      env: Salad.env

    options = _.extend defaultOptions, options

    # transform class representations of models to JSON data
    # otherwise handlebars can't handle them
    for key, val of options
      if val instanceof Array
        options[key] = (a.toJSON() for a in val)
      if val?.toJSON
        options[key] = val.toJSON()

    content = @_render file, options

    if options.layout
      layoutOptions = _.extend options, content: content

      content = @_render "layouts/#{options.layout}", layoutOptions

    content

  @_render: (file, options) ->
    Salad.Template.Handlebars.render file, options

require "./templates/handlebars"