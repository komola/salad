/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
Salad.Mailer.Debug = class Debug {
  static mail(options, callback) {
    const email = options.message;

    return callback(null, email);
  }
};
