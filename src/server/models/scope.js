/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
Salad.Scope = class Scope {
  constructor(context) {
    this.context = context;
    this.daoContext = this.context.daoInstance;
    this.data = {
      conditions: {},
      contains: [],
      includes: [],
      order: [],
      limit: -1,
      offset: 0
    };
  }

  /*
  Usage:
    * id has to equal "value"
    scope.where(id: "value")

    * id has to be IN [1, 2, 3]
    scope.where(id: [1, 2, 3])
  */
  where(attributes) {
    if (typeof(attributes) !== "object") {
      throw new Error("where() only accepts an object as argument!");
    }

    for (let key in attributes) {
      const val = attributes[key];
      this.data.conditions[key] = val;
    }

    return this;
  }

  asc(field) {
    this.data.order.push({
      field,
      type: "asc"
    });

    return this;
  }

  desc(field) {
    this.data.order.push({
      field,
      type: "desc"
    });

    return this;
  }

  contains(field, value) {
    this.data.contains.push({
      field,
      value
    });

    return this;
  }

  _normalizeInclude(include) {
    // includes should always have one of the following forms:
    // {model: Operator, …} where Operator is a subclass of Salad.Model
    // {association: "Operators", …} where the association has been registered before
    // however we allow calls like Scope.includes([Operator]) or Scope.includes(["Operators"])
    // this method transforms the last forms to the normal form
    // NO sanity checking is happening in this method

    if ((include === null) || (include === undefined)) {
      throw new Error("Scope::includes - Value of include must not be null");
    }

    if (typeof include === "string") {
      // this must be an association
      return {association: include};
    } else if (include.__super__ === Salad.Model.prototype) {
      return {model: include};
    }

    return include;
  }


  // Eager-load models
  //
  // Usage:
  //
  // App.Location.includes([App.Operator])
  //
  // App.Location.includes(["Operator"])
  //
  // App.Location.includes([{model: App.Operator, includes: [App.Cat]}])
  //
  // App.Location.includes([{association: "Operators", includes: ["Cats"]}]
  //
  // or a mix of the last two
  includes(includesArray) {
    for (let include of Array.from(includesArray)) {
      var model;
      let option = {};
      let field = null;
      let includes = [];

      let saladModel = {};

      include = this._normalizeInclude(include);

      if (include.model) {
        if (include.model.__super__ !== Salad.Model.prototype) {
          throw new Error("Scope::includes - Value of key 'model' has to be of type Salad.Model");
        }

        ({ model } = include);
        const { associations } = this.context.metadata();

        for (let key in associations) {
          const currentAssociation = associations[key];
          if (currentAssociation.model === model) {
            field = currentAssociation.as;
            break;
          }
        }
        saladModel = model;
        model = model.daoInstance;

      } else if (include.association) {
        if (typeof include.association !== "string") {
          throw new Error("Scope::includes - Value of key 'association' has to be a string");
        }

        if (this.context.hasAssociation(include.association)) {
          field = include.association;
          saladModel = this.context.getAssociation(include.association);
          model = saladModel.daoInstance;
        }
      }

      if (include.includes) {
        // the included model requests other models to be included
        includes = includes.concat(this._includeNestedIncludes(saladModel,include.includes));
      }

      if (!field) {
        throw new Error(`Scope::includes - Could not find an association between ${this.context.name} and ${model}`);
      }

      option = {
        model,
        as: field
      };

      if (includes.length !== 0) {
        option.includes = includes;
      }

      this.data.includes.push(option);
    }

    return this;
  }

  _includeNestedIncludes(model,nestedIncludes) {
    let nestedScopes = [];
    for (let nestedInclude of Array.from(nestedIncludes)) {
      const nestedScope = model.includes([nestedInclude]);
      nestedScopes = nestedScopes.concat(nestedScope.data.includes);
    }

    return nestedScopes;
  }

  limit(limit) {
    this.data.limit = parseInt(limit, 10);

    return this;
  }

  offset(offset) {
    this.data.offset = parseInt(offset, 10);

    return this;
  }

  nil() {
    this.data.nil = true;

    return this;
  }

  count(callback) {
    const options = _.clone(this.data, true);

    if (options.nil) {
      return callback(null, 0);
    }

    if (options.offset) {
      delete options.offset;
    }

    if (options.includes) {
      delete options.includes;
    }

    if (options.limit) {
      delete options.limit;
    }

    if (options.order) {
      options.order = [];
    }

    this.daoContext.count(options, callback);
    return null;
  }

  all(callback) {
    const options = this.data;

    if (options.nil) {
      return callback(null, []);
    }

    this.daoContext.findAll(options, callback);
    return null;
  }

  first(callback) {
    const options = this.data;
    options.limit = 1;

    this.all((err, resources) => {
      if (resources instanceof Array) {
        resources = resources[0];
      }

      return callback(err, resources);
    });

    return null;
  }

  find(id, callback) {
    this.where({id}).first(callback);
    return null;
  }

  findAndCountAll(callback) {

    this.all((err, resources) => {
      return this.count((err, count) => {
        const result = {
          count,
          rows: resources
        };

        return callback(err, result);
      });
    });
    return null;
  }

  // create object
  create(data, callback) {
    const attributes = _.extend(this.data.conditions, data);

    this.context.create(attributes, callback);
    return null;
  }

  // build an instance
  build(data) {
    const attributes = _.extend(this.data.conditions, data);

    return this.context.build(attributes);
  }

  destroy(callback) {
    const options = this.data;

    this.daoContext.destroy(options, callback);
    return null;
  }

  // remove associations
  remove(model, callback) {
    const keys = _.keys(this.data.conditions);

    for (let key of Array.from(keys)) { model.set(key, null); }

    model.save(callback);
    return null;
  }
};
