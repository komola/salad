module.exports =
  InstanceMethods:
    render: (options) ->
      # render template: @render "foo/bar", model: @resource
      unless typeof(options) is "object"
        templateOptions = arguments[1] or {}

        options =
          template: options
          data: templateOptions

        if templateOptions.status
          options.status = templateOptions.status

        if templateOptions.layout isnt undefined
          options.layout = templateOptions.layout
          delete templateOptions.layout

      @_render options

    _render: (options) ->
      defaultOptions =
        env: Salad.env

      options = _.extend defaultOptions, options

      content = Salad.Template.render options.template, options.data

      content
