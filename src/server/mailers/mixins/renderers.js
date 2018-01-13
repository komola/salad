/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  InstanceMethods: {
    render(options) {
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

      return this._render(options);
    },

    _render(options) {
      const defaultOptions =
        {env: Salad.env};

      options = _.extend(defaultOptions, options);

      const content = Salad.Template.render(options.template, options.data);

      return content;
    }
  }
};
