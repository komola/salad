/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let check, sanitize, validator;
if (typeof window === 'undefined' || window === null) {
  validator = require("validator");
  ({check, sanitize} = validator);

} else {
  ({check, sanitize} = window);
  window.Salad = (typeof Salad !== 'undefined' && Salad !== null) || {};
}

Salad.Validator = class Validator {
  static check(attributes, checks) {
    let errors = false;

    for (let field in checks) {
      const validators = checks[field];
      if (!attributes[field] &&
        !validators.notEmpty &&
        !validators.notNull) {

          continue;
        }

      for (validator in validators) {
        var message;
        const options = validators[validator];
        try {
          let fieldCheck = undefined;
          let passedOptions = _.clone(options);

          // custom error message
          if (_.isString(options) || options.message) {
            message = _.isString(options) ? options : options.message;

            fieldCheck = check(attributes[field], message);

          } else {
            fieldCheck = check(attributes[field]);
          }

          if (options.options) {
            passedOptions = options.options;
          }

          fieldCheck[validator](passedOptions);
        } catch (e) {
          if (!errors) { errors = {}; }
          if (!errors[field]) { errors[field] = []; }
          errors[field].push(e.message);
        }
      }
    }

    const result = errors ? errors : true;

    return result;
  }
};
