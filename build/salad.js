(function() {
  var check, sanitize, validator;

  if (typeof window === "undefined" || window === null) {
    validator = require("validator");
    check = validator.check, sanitize = validator.sanitize;
  } else {
    check = window.check, sanitize = window.sanitize;
    window.Salad = (typeof Salad !== "undefined" && Salad !== null) || {};
  }

  Salad.Validator = (function() {
    function Validator() {}

    Validator.check = function(attributes, checks) {
      var e, errors, field, fieldCheck, message, options, passedOptions, result, validators;
      errors = false;
      for (field in checks) {
        validators = checks[field];
        if (!attributes[field] && !validators.notEmpty && !validators.notNull) {
          continue;
        }
        for (validator in validators) {
          options = validators[validator];
          try {
            fieldCheck = void 0;
            passedOptions = _.clone(options);
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
          } catch (_error) {
            e = _error;
            errors || (errors = {});
            errors[field] || (errors[field] = []);
            errors[field].push(e.message);
          }
        }
      }
      result = errors ? errors : true;
      return result;
    };

    return Validator;

  })();

}).call(this);
