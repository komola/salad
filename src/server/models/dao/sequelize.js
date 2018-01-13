// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
Salad.DAO.Sequelize = class Sequelize extends Salad.DAO.Base {
  constructor(...args) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    this.lazyInstantiate = this.lazyInstantiate.bind(this);
    this._cleanAttributes = this._cleanAttributes.bind(this);
    this._buildModelInstance = this._buildModelInstance.bind(this);
    this.increment = this.increment.bind(this);
    this.decrement = this.decrement.bind(this);
    super(...args);
  }

  create(attributes, callback) {
    attributes = this._cleanAttributes(attributes);
    const options = {};

    if (App.transaction) {
      options.transaction = App.transaction;
    }

    const query = this.daoModelInstance.create(attributes, options);

    query.then(daoResource => {
      const resource = this._buildModelInstance(daoResource);
      return callback(null, resource);
    });

    return query.catch(error => {
      if (Salad.env !== "test") {
        App.Logger.error("Create: Query returned error", {
          sql: error.sql,
          attributes
        }
        );
        App.Logger.error(error);
      }

      return callback(error);
    });
  }

  // TODO: Optimize this. Right now this would create an additional select and update
  // query for each update operation.
  // We could use a instance hash of all daoModel objects and then just update those
  _getSequelizeModelBySaladModel(model, callback) {
    const options = {};

    if (App.transaction) {
      options.transaction = App.transaction;
    }

    const conditions = {
      where: {
        id: model.get("id")
      }
    };

    const query = this.daoModelInstance.find(conditions, options);

    query.then(sequelizeModel => {
      if (!sequelizeModel) {
        const error = new Error(`Could not find model with id: ${model.get("id")}`);
        return callback(error);
      }

      return callback(null, sequelizeModel);
    });

    return query.catch(error => {
      if (Salad.env !== "test") {
        App.Logger.error("Find: Query returned error", {
          sql: error.sql,
          conditions
        }
        );
        App.Logger.error(error);
      }

      return callback(error);
    });
  }

  update(model, attributes, callback) {
    return this._getSequelizeModelBySaladModel(model, (err, sequelizeModel) => {
      if (err) { return callback(err); }

      const options =
        {fields: _.keys(attributes)};

      if (App.transaction) {
        options.transaction = App.transaction;
      }

      const query = sequelizeModel.updateAttributes(attributes, options);

      query.then(daoResource => {
        const resource = this._buildModelInstance(daoResource);
        return callback(null, resource);
      });

      return query.catch(error => {
        if (Salad.env !== "test") {
          App.Logger.error("Update: Query returned error", {
            sql: error.sql,
            attributes,
            options: _.omit(options, "transaction")
          }
          );

          App.Logger.error(error);
        }

        return callback(error);
      });
    });
  }

  /*
  Destroy models in the database

  Usage:
    * destroy single instance
    App.Todo.first (err, todo) =>
      todo.destroy()

    * destroy all objects
    App.Todo.destroy (err) =>
      console.log "everything gone"
  */
  destroy(model, callback) {
    if (model instanceof Salad.Model) {
      return this._getSequelizeModelBySaladModel(model, (err, sequelizeModel) => {
        if (err) { return callback(err); }

        const options = {};

        if (App.transaction) {
          options.transaction = App.transaction;
        }

        const query = sequelizeModel.destroy(options);

        query.then(() => {
          return callback(null);
        });

        return query.catch(error => {
          if (Salad.env !== "test") {
            App.Logger.error("Destroy: Query returned error",
              {sql: error.sql});
            App.Logger.error(error);
          }

          return callback(error);
        });
      });

    } else {
      const sequelizeModel = this.daoModelInstance;

      const options = {};

      if (App.transaction) {
        options.transaction = App.transaction;
      }

      options.where = model.conditions;

      const query = sequelizeModel.destroy(options);

      query.then(() => {
        return callback(null);
      });

      return query.catch(error => {
        if (Salad.env !== "test") {
          App.Logger.error("Query returned error",
            {sql: error.sql});
          App.Logger.error(error);
        }

        return callback(error);
      });
    }
  }

  findAll(options, callback) {
    const params = this._buildOptions(options);

    if (App.transaction) {
      params.transaction = App.transaction;
    }

    const query = this.daoModelInstance.findAll(params);

    query.then(rawResources => {
      const resources = [];

      for (let res of Array.from(rawResources)) {
        resources.push(this._buildModelInstance(res));
      }

      return callback(null, resources);
    });

    return query.catch(error => {
      if (Salad.env !== "test") {
        App.Logger.error("findAll: Query returned error", {
          sql: error.sql,
          parameter: params
        }
        );
        App.Logger.error(error);
      }

      return callback(error);
    });
  }

  count(options, callback) {
    const params = this._buildOptions(options);

    if (App.transaction) {
      params.transaction = App.transaction;
    }

    const query = this.daoModelInstance.count(params);

    query.then(count => {
        return callback(null, count);
    });

    return query.catch(error => {
      if (Salad.env !== "test") {
        App.Logger.error("Count: Query returned error", {
          sql: error.sql,
          parameter: params
        }
        );
        App.Logger.error(error);
      }

      return callback(error);
    });
  }

  lazyInstantiate(daoInstance) {
    return this._buildModelInstance(daoInstance);
  }

  _cleanAttributes(rawAttributes) {
    const attributes = {};
    for (let key in rawAttributes) { const val = rawAttributes[key]; if (val !== null) { attributes[key] = val; } }

    return attributes;
  }

  _buildModelInstance(daoInstance) {
    const options = {
      isNew: false,
      daoInstance: this,
      eagerlyLoadedAssociations: {}
    };

    // make a copy of the datavalues.
    // the possibly eagerloaded associations will be removed from this
    // object later because they are initialized in a different way
    const dataValues = _.clone(daoInstance.dataValues);

    const associationKeys = _.map(this.modelClass.metadata().associations, "as");

    // TODO: When does this happen? Seems like dataValues is null
    for (let key of Array.from(associationKeys)) {
      if ((dataValues != null ? dataValues[key] : undefined)) {
        delete dataValues[key];

        // fetch the association model class from the associations object
        const associationModelClass = this.modelClass.getAssociation(key);
        const associationType = this.modelClass.getAssociationType(key);

        let daoModels = daoInstance.dataValues[key];
        let models = null;

        if (daoModels === null) {
          continue;
        }

        // create an instance of the associated model passing along our dao model instance
        if (associationType === "belongsTo") {
          daoModels = [daoModels];
        }

        models = daoModels.map(associationModelClass.daoInstance.lazyInstantiate);

        // Unwrap the model from the array if it is a belongsTo association.
        // There can only be one association of this model
        if (associationType === "belongsTo") {
          models = models[0];
        }

        key = key[0].toLowerCase() + key.substr(1);

        // add the instance to the options, so the constructor of modelInstance
        // model can pick them up
        options.eagerlyLoadedAssociations[key] = models;
      }
    }

    const attributes = dataValues;

    return new this.modelClass(attributes, options);
  }

  _buildOptions(options) {
    const params = {};

    if (_.keys(options.conditions).length > 0) {
      params.where = options.conditions;
    }

    if (options.limit > 0) {
      params.limit = options.limit;
    }

    if (options.offset > 0) {
      params.offset = options.offset;
    }

    if (options.order.length > 0) {
      // transform the order params into i.e. 'name DESC'
      const order = [];
      for (let elm of Array.from(options.order)) {
        order.push([
          // BUG this will cause problems with mysql drivers because the
          // escaping is off
          `\"${elm.field}\"`,
          elm.type.toUpperCase()
        ]);
      }

      params.order = order;
    }

    if (options.contains.length > 0) {
      const tableName = this.modelClass.daoInstance.daoModelInstance.name;

      if (!params.where) { params.where = {}; }

      for (let contains of Array.from(options.contains)) {
        params.where[contains.field] = {
          "$contains": [contains.value]
        };
      }
    }

    if (params.limit === -1) {
      delete params.limit;
    }

    if ((options.includes != null ? options.includes.length : undefined) > 0) {
      params.include = [];
      for (let option of Array.from(options.includes)) {
        option = this._transformInclude(option);

        params.include.push(option);
      }
    }

    return params;
  }

  _transformInclude(include) {
    if ((typeof include === "object") && include.as) {
      include.model = include.model.daoModelInstance;
      if (include.includes) {
        const nestedIncludes = [];
        for (let nestedInclude of Array.from(include.includes)) {
          nestedIncludes.push(this._transformInclude(nestedInclude));
        }
        delete include.includes;
        include.include = nestedIncludes;
      }
    }
    return include;
  }


  /*
  Increment the field of a model.

  This prevents concurrency issues

  Usage:
    App.Model.first (err, model) =>
      model.increment "field", 3, (err, newModel) =>
        console.log model.get("field") is newModel.get("field") # => true
  */
  increment(model, field, change, callback) {
    return this._getSequelizeModelBySaladModel(model, (err, sequelizeModel) => {
      if (err) { return callback(err); }

      const successCallback = daoResource => {
        const resource = this._buildModelInstance(daoResource);

        return callback(null, resource);
      };

      const options = {};

      if (typeof field === "object") {
        options.by = 1;
      } else {
        options.by = change;
      }

      if (App.transaction) {
        options.transaction = App.transaction;
      }

      return sequelizeModel.increment(field, options).then(successCallback);
    });
  }

  /*
  Decrement the field of a model

  This prevents concurrency issues

  Usage:
    App.Model.first (err, model) =>
      model.decrement "field", 3, (err, newModel) =>
        console.log model.get("field") is newModel.get("field") # => true
  */
  decrement(model, field, change, callback) {
    return this._getSequelizeModelBySaladModel(model, (err, sequelizeModel) => {
      if (err) { return callback(err); }

      const successCallback = daoResource => {
        const resource = this._buildModelInstance(daoResource);

        return callback(null, resource);
      };

      const options = {};

      if (typeof field === "object") {
        options.by = 1;
      } else {
        options.by = change;
      }

      if (App.transaction) {
        options.transaction = App.transaction;
      }

      return sequelizeModel.decrement(field, options).then(successCallback);
    });
  }
};
