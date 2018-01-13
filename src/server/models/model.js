/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const async = require("async");

const Cls = (Salad.Model = class Model extends Salad.Base {
  static initClass() {
    this.mixin(require("../mixins/metadata"));
    this.mixin(require("../mixins/triggers"));
    this.mixin(require("./mixins/attributes"));
    this.mixin(require("./mixins/changes"));
    this.mixin(require("./mixins/associations"));
    this.mixin(require("./mixins/scope"));
    this.mixin(require("./mixins/validation"));
  
    this.before("save", "validate");
    this.after("save", "takeSnapshot");
  
    this.prototype.daoInstance = undefined;
    this.prototype.eagerlyLoadedAssociations = {};
    this.prototype.isNew = true;
    this.prototype.triggerStack = {};
  }

  constructor(attributes, options) {
    // overwrite default options with passed options
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    this.save = this.save.bind(this);
    this.verifyAssociationsExist = this.verifyAssociationsExist.bind(this);
    this.increment = this.increment.bind(this);
    this.decrement = this.decrement.bind(this);
    options = _.extend({isNew: true}, options);

    this.eagerlyLoadedAssociations = options.eagerlyLoadedAssociations || {};
    this.isNew = options.isNew;

    this.setAttributes(attributes);

    if (!this.isNew) {
      this.takeSnapshot();
    }

    if (!options.daoInstance) {
      throw new Error("No DAO instance set!");
    }

    this.daoInstance = options.daoInstance;
  }

  //# DAO functionality #################################
  static dao(options) {
    return this.daoInstance = new Salad.DAO.Sequelize(options.instance, this);
  }

  static build(attributes) {
    if (!this.daoInstance) {
      return (() => { throw new Error("No DAO object is set!"); })();
    }

    const options =
      {daoInstance: this.daoInstance};

    const resource = new (this)(attributes, options);

    return resource;
  }

  static create(attributes, callback) {
    if (!this.daoInstance) {
      return (() => { throw new Error("No DAO object is set!"); })();
    }

    let err = undefined;
    let resource = this.build(attributes);

    return async.series([
      cb => resource.runTriggers("before:create", cb),
      cb => { return resource.save((_err, _res) => {
        err = _err;
        resource = _res;

        return cb(err);
      }); },
      cb => resource.runTriggers("after:create", cb)
    ], () => {
      return callback(err, resource);
    });
  }

  updateAttributes(attributes, callback) {
    this.setAttributes(attributes);

    this.save(callback);
    return null;
  }

  save(callback) {
    let resource = null;

    const action = cb => {
      if (this.isNew) {
        return this.daoInstance.create(this.getAttributes(), (_err, _res) => {
          resource = _res;
          return cb(_err);
        });
      }

      const changedAttributes = _.keys(this.getChangedAttributes());
      const delta = _.pick(this.getAttributes(), changedAttributes);

      return this.daoInstance.update(this, delta, (_err, _res) => {
        resource = _res;
        return cb(_err);
      });
    };

    async.series([
        cb => this.runTriggers("before:save", err => {
          return cb(err);
        }),
        cb => this.verifyAssociationsExist(cb),
        action,
        cb => {
          this.isNew = false;
          this.set("id", resource.get("id"));
          return cb();
        },
        cb => this.runTriggers("after:save", cb)
      ],

      err => {
        if (callback) {
          return callback(err, resource);
        }
    });

    return null;
  }

  /*
  Helper function that is called when calling save.
  It verifies that all the associations actually exist before writing to the
  database.

  Calls the callback with an error if an invalid association was found.
  */
  verifyAssociationsExist(callback) {
    const { associations } = this.metadata();
    const attributes = this.getAttributes();

    const checkForeignKey = (name, cb) => {
      const {foreignKey} = associations[name];

      // only check for models that "own" the association and that contain the
      // foreignKey attribute
      if (!associations[name].isOwning) { return cb(); }

      const value = attributes[foreignKey];

      // skip the check if there is no value provided for this field
      if (!value) { return cb(); }

      const modelClass = associations[name].model;

      return modelClass.where({id: value}).count((err, count) => {
        if (err) { return cb(err); }
        if (count > 0) { return cb(); }

        const error = new Error(`Invalid value for ${foreignKey}. No resource found with ID ${value}`);
        error.isValid = false;
        return cb(error);
      });
    };

    async.eachSeries(_.keys(associations), checkForeignKey, callback);
    return null;
  }

  /*
  Increment the field or fields of a model

  Usage:
    * Increment a field by 1:
    model.increment "counter", (err, res) =>
      console.log model.get("counter") is res.get("counter") # => true

    * Increment by a specific value:
    model.increment "counter", 3, (err, res) =>
      console.log model.get("counter") is res.get("counter") # => true

    * Increment multiple fields:
    model.increment counter: 1, counterB: 3, (err, res) =>
      console.log model.get("counter") is res.get("counter") # => true
      console.log model.get("counterB") is res.get("counterB") # => true
  */
  increment(field, value, callback) {
    if (typeof value === "function") {
      callback = value;
      value = 1;
    }

    this.daoInstance.increment(this, field, value, (err, model) => {
      let key;
      if (err) { return callback(err); }

      if (typeof field !== "object") {
        key = field;
        field = {};
        field[key] = model.get(key);
      }

      for (key in field) {
        const val = field[key];
        this.set(key, model.get(key));
      }

      return callback(err, model);
    });

    return null;
  }

  /*
  Decrement the field of a model.

  See @increment for usage options
  */
  decrement(field, value, callback) {
    if (typeof value === "function") {
      callback = value;
      value = 1;
    }

    this.daoInstance.decrement(this, field, value, (err, model) => {
      let key;
      if (err) { return callback(err); }

      if (typeof field !== "object") {
        key = field;
        field = {};
        field[key] = model.get(key);
      }

      for (key in field) {
        const val = field[key];
        this.set(key, model.get(key));
      }

      return callback(err, model);
    });
    return null;
  }

  destroy(callback) {
    this.daoInstance.destroy(this, callback);
    return null;
  }

  //# Misc stuff #########################################
  toJSON() {
    const associations = this.getAssociations();

    for (let key in associations) {
      if (associations[key] instanceof Array) {
        associations[key] = (Array.from(associations[key]).map((model) => model.toJSON()));

      } else {
        associations[key] = associations[key].toJSON();
      }
    }

    const attributes = _.extend(this.getAttributes(), associations);

    return attributes;
  }

  toString() {
    return this.constructor.name;
  }

  // Helpful method
  // This is called when console.log modelInstance is called
  inspect() {
    let data;
    const attributes = this.toJSON();
    const methods = _.keys(this);

    return data = {
      attributes,
      methods
    };
  }
});
Cls.initClass();
