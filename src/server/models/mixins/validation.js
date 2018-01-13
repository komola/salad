// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  InstanceMethods: {
    validate(done) {
      const result = this.isValid(this.getAttributes());
      let error = null;

      if (result !== true) {
        error = new Error("ValidationError");
        error.isValid = false;
        error.errors = result;
      }

      return done(error);
    },

    // Check if the passed attributes are valid
    //
    // This method should return true if the data is valid.
    //
    // Otherwise it should return an object containing detailed errors
    // for each field.
    isValid(attributes) { return true; }
  }
};

