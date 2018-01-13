/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const email = require("emailjs/email");

Salad.Mailer.Smtp = class Smtp {
  static mail(options, callback) {
    const defaultOptions = {
      credentials: {
        user: "",
        password: "",
        host: "",
        ssl: true
      },
      message: {
        to: "",
        from: "",
        cc: undefined,
        subject: undefined,
        text: undefined,
        html: undefined,
        attachments: [],
        options: undefined
      }
    };

    options = _.extend(defaultOptions, options);
    
    // Check if html is specified and attach it to the email as an alternative.
    if (options.message.html !== undefined) {
      if (!options.message.attachments) {
        options.message.attachments = [];
      }

      options.message.attachments.push({data:options.message.html, alternative:true});
    }
    delete options.message.html;
    
    // Rename attachments to attachment for emailjs api
    options.message.attachment = options.message.attachments;
    delete options.message.attachments;

    const connection = email.server.connect(options.credentials);

    if (options.message.options != null ? options.message.options.headers : undefined) {
      options.message = _.extend(options.message, options.message.options.headers);

      delete options.message.options.headers;
    }

    delete options.message.options;

    return connection.send(options.message, callback);
  }
};
