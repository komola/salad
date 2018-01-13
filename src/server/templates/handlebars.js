/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const handlebars = require("handlebars");

const Cls = (Salad.Template.Handlebars = class Handlebars {
  static initClass() {
    this.prototype.registeredPartials = false;
  }

  // render a template, passing the options to the template and returning an
  // html string
  static render(template, options) {
    this._registerPartials();

    template = this.compile(template);
    const renderedTemplate = template(options);

    return renderedTemplate;
  }

  // compile a handlebars template into a function that can get called
  // to render the content
  static compile(template) {
    template = `${template}.hbs`;

    if (!(template in Salad.Bootstrap.metadata().templates)) {
      throw new Error(`Template ${template} does not exist!`);
    }

    const templateContent = Salad.Bootstrap.metadata().templates[template];
    template = handlebars.compile(templateContent);

    return template;
  }

  // register a single partial
  static registerPartial(file, content) {
    const fileParts = file.split("/");

    // partials start with an underscore in their name
    if ((fileParts[1] != null ? fileParts[1].substr(0, 1) : undefined) !== "_") { return; }

    file = file.replace(".hbs", "");
    return handlebars.registerPartial(file, content);
  }

  // registers all partials that were found during Salad.Bootstraps bootstrapping.
  // partials have to start with an underscore in their name: controller/_partial.hbs
  static _registerPartials() {
    if (this.registeredPartials) { return; }

    this.registeredPartials = true;

    return (() => {
      const result = [];
      const object = Salad.Bootstrap.metadata().templates;
      for (let file in object) {
        const content = object[file];
        result.push(this.registerPartial(file, content));
      }
      return result;
    })();
  }
});
Cls.initClass();
