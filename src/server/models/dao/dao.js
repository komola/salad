/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
Salad.DAO = {};

const Cls = (Salad.DAO.Base = class Base {
  static initClass() {
    this.prototype.daoModelInstance = undefined;
    this.prototype.modelInstance = undefined;
  }

  constructor(daoModelInstance, modelClass) {
    this.daoModelInstance = daoModelInstance;
    this.modelClass = modelClass;
  }

  create(attributes, callback) {}
  update(model, changes, callback) {}
  findAll(options, callback) {}
  count(options, callback) {}
  destroy(model, callback) {}
  increment(model, field, change, callback) {}
  decrement(model, field, change, callback) {}
});
Cls.initClass();

// class Salad.DAO.Memory
//   store: {}

//   create: (attributes, callback) ->
//     @store[@daoModelInstance] or= []
//     @store[@daoModelInstance].push attributes

