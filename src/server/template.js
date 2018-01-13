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

    options = @serialize options

    content = @_render file, options

    if options.layout
      layoutOptions = _.extend options, content: content

      content = @_render "layouts/#{options.layout}", layoutOptions

    content

  @_render: (file, options) ->
    Salad.Template.Handlebars.render file, options

  # transform class representations of models to JSON data
  # otherwise handlebars can't handle them
  @serialize: (elm) =>
    # if elm has a toJSON method it's easy
    if elm?.toJSON
      return elm.toJSON()

    # call serialize on the array
    if _.isArray elm
      elm = elm.map @serialize
      return elm

    # call serialize on all properties of the object
    if _.isObject elm
      for key, val of elm
        elm[key] = @serialize val

    elm

require "./templates/handlebars"
