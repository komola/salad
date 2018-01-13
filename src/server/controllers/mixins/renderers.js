/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  ClassMethods: {
    // set the default layout for this controller
    layout(name) {
      return this.metadata().layout = name;
    }
  },

  InstanceMethods: {
    // use this to offer different response formats in your controller.
    // example:
    /*
    index: ->
      @_index (error, resources) =>
        @respondWith
          html: -> "Ich habe #{resources.length} Einträge"
          json: -> @render json: resources

    */
    respondWith(formats) {
      let format = this.params.format || "html";
      if (!formats[format]) { format = "html"; }

      return formats[format].apply(this);
    },

    /*
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
    */
    render(options) {
      // don't render twice
      if (this.isRendered) { return; }
      this.isRendered = true;

      // render template: @render "foo/bar", model: @resource
      if (typeof(options) !== "object") {
        const templateOptions = arguments[1] || {};

        options = {
          template: options,
          data: templateOptions
        };

        if (templateOptions.status) {
          options.status = templateOptions.status;
        }

        if (templateOptions.layout !== undefined) {
          options.layout = templateOptions.layout;
          delete templateOptions.layout;
        }
      }

      const defaultOptions = {
        status: 200,
        layout: this.metadata().layout,
        data: undefined
      };

      options = _.extend(defaultOptions, options);

      this.response.status(options.status);

      // Render JSON response
      if (options.json) {
        this.json(options.json);

      } else {
        this.html(options);
      }

      return this.emit("render");
    },

    // method to render the actual layout
    html(options) {
      const defaultOptions = {
        env: Salad.env,
        request: this.request
      };

      options = _.extend(defaultOptions, options);
      options.data.layout = options.layout;

      const content = Salad.Template.render(options.template, options.data);

      return this.response.send(content);
    },

    // send the JSON response to the client and set correct content-type headers
    json(data) {
      this.response.set("Content-Type", "application/json; charset=utf-8");
      return this.response.send(data);
    }
  }
};
