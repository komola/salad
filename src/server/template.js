// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Cls = (Salad.Template = class Template {
  static initClass() {
  
    // transform class representations of models to JSON data
    // otherwise handlebars can't handle them
    this.serialize = elm => {
      // if elm has a toJSON method it's easy
      if (elm != null ? elm.toJSON : undefined) {
        return elm.toJSON();
      }
  
      // call serialize on the array
      if (_.isArray(elm)) {
        elm = elm.map(this.serialize);
        return elm;
      }
  
      // call serialize on all properties of the object
      if (_.isObject(elm)) {
        for (let key in elm) {
          const val = elm[key];
          elm[key] = this.serialize(val);
        }
      }
  
      return elm;
    };
  }
  /*
  Render a template

  Mostly used in Salads Controllers and Mailers.

  Usage:
    Salad.Template.render "user/show", user: userModel

    * with layout:
    Salad.Template.render "user/show", user: userModel, layout: "application"
  */
  static render(file, options) {
    const defaultOptions =
      {env: Salad.env};

    options = _.extend(defaultOptions, options);

    options = this.serialize(options);

    let content = this._render(file, options);

    if (options.layout) {
      const layoutOptions = _.extend(options, {content});

      content = this._render(`layouts/${options.layout}`, layoutOptions);
    }

    return content;
  }

  static _render(file, options) {
    return Salad.Template.Handlebars.render(file, options);
  }
});
Cls.initClass();

require("./templates/handlebars");
