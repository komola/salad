// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//# Data retrieval #####################################
//# These are pretty much just proxy methods that insantiate
//# a scope and pass the parameters on to the scope

module.exports = {
  ClassMethods: {
    // Builds a new scope with the current dao instance as context
    scope() {
      return new Salad.Scope(this);
    },

    where(attributes) {
      return this.scope().where(attributes);
    },

    limit(limit) {
      return this.scope().limit(limit);
    },

    offset(offset) {
      return this.scope().offset(offset);
    },

    nil(nil) {
      return this.scope().nil();
    },

    asc(field) {
      return this.scope().asc(field);
    },

    desc(field) {
      return this.scope().desc(field);
    },

    contains(field, value) {
      return this.scope().contains(field, value);
    },

    includes(models) {
      return this.scope().includes(models);
    },

    all(callback) {
      return this.scope().all(callback);
    },

    first(callback) {
      return this.scope().first(callback);
    },

    count(callback) {
      return this.scope().count(callback);
    },

    find(id, callback) {
      return this.scope().find(id, callback);
    },

    findAndCountAll(callback) {
      return this.scope().findAndCountAll(callback);
    },

    destroy(callback) {
      return this.scope().destroy(callback);
    }
  }
};