// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
Salad.Base = class Base {
  // For static methods
  static extend(obj) {
    return _.extend(this, obj);
  }

  // For instance methods
  static include(obj) {
    for (let key in obj) {
      // Assign properties to the prototype
      const value = obj[key];
      this.prototype[key] = value;
    }

    return this;
  }

  static mixin(obj) {
    if (obj.ClassMethods) { this.extend(obj.ClassMethods); }
    if (obj.InstanceMethods) { return this.include(obj.InstanceMethods); }
  }
};
