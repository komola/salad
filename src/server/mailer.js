// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Cls = (Salad.Mailer = class Mailer extends Salad.Base {
  static initClass() {
    this.mixin(require("./mailers/mixins/renderers"));
  }

  mail(options, callback) {
    const defaultOptions = {
      subject: "",
      to: "",
      from: "",
      options: null
    };

    options = _.extend(defaultOptions, options);

    if (!options.to) {
      throw new Error("No recipient given!");
    }

    if (options.html) {
      options.html = options.html();
    }

    if (options.text) {
      options.text = options.text();
    }

    const emailConnection = Salad.Config.mailer[Salad.env];
    const transport = this.getTransport(emailConnection.transport);

    const mailOptions = {
      credentials: emailConnection,
      message: options
    };

    return transport.mail(mailOptions, callback);
  }

  getTransport(name) {
    name = _.classify(name);
    const transport = Salad.Mailer[name];

    if (!transport) {
      throw new Error(`Could not find email transport ${name}`);
    }

    return transport;
  }
});
Cls.initClass();

require("./mailers/smtp");
require("./mailers/debug");