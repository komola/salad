// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const fs = require("fs");

if (!Salad.Utils) { Salad.Utils = {}; }

Salad.Utils.Models = class Models {
  /*
  Returns an array of all available models in the current app.

  This is useful for automatically loading fixtures.

  Usage:
    models = Salad.Utils.Models.registered()
  */
  static registered() {
    const namespace = App;
    const models = [];

    for (let modelName in App) {
      const modelClass = App[modelName];
      if (modelClass.prototype instanceof Salad.Model) {
        models.push(modelClass);
      }
    }

    return models;
  }

  static resolvedRegistered() {
    const models = this.registered();

    const resolvedDependencies = [];
    const processed = [];

    // build dependency tree
    for (let model of Array.from(models)) {
      this._buildDependencyTree(model, resolvedDependencies, processed);
    }

    return resolvedDependencies;
  }

  /*
  Return the corresponding database tables of all the models in our app.

  Usage:
    tables = Salad.Utils.existingDatabaseTables()
  */
  static existingDatabaseTables() {
    const models = this.resolvedRegistered();

    const tables = (Array.from(models).map((model) => model.daoInstance.daoModelInstance.tableName));
    tables.push("SequelizeMeta");

    return tables;
  }

  static loadFixtures(path, callback) {
    let name;
    const models = this.resolvedRegistered();

    const modelToFixtureFile = [];

    for (let model of Array.from(models)) {
      name = _.pluralize(model.name);
      name = name.substr(0, 1).toLowerCase() + name.substr(1);

      modelToFixtureFile.push({
        name: model.name,
        model,
        file: name
      });
    }

    const modelInstances = {};
    const fixtureData = {};

    const createData = (element, cb) => {
      const fixturePath = `${path}/${element.file}`;

      return fs.exists(`${fixturePath}.coffee`, exists => {
        if (!exists) { return cb(); }

        const data = require(fixturePath);

        const modelCreator = (attributes, _cb) => {
          return element.model.create(attributes, (err, res) => {
            if (err) { throw err; }
            if (!modelInstances[element.name]) { modelInstances[element.name] = []; }
            modelInstances[element.name].push(res);

            if (!fixtureData[element.name]) { fixtureData[element.name] = []; }
            fixtureData[element.name].push(attributes);

            return _cb(err);
          });
        };

        return async.eachSeries(data, modelCreator, cb);
      });
    };

    return async.eachSeries(modelToFixtureFile, createData, err => {
      return callback(err, {instances: modelInstances, data: fixtureData});
  });
  }

  static _buildDependencyTree(model, resolvedDependencies, processed) {
    // model was already processed. Skip
    if (Array.from(processed).includes(model.name)) { return; }

    // get the models association
    const { associations } = model.metadata();

    // mark the model as processed
    processed.push(model.name);

    // iterate over all owning associations
    // owning means, that the association stores the relation information
    // (i.e. has userId column).
    for (let name in associations) {
      const options = associations[name];
      if (options.isOwning && !options.isWeak) {
        const dependentModel = options.model;
        // build the dependency tree for every associated model
        this._buildDependencyTree(dependentModel, resolvedDependencies, processed);
      }
    }

    return resolvedDependencies.push(model);
  }

  static emptyTables(callback) {
    let tables = this.existingDatabaseTables();

    // remove SequelizeMeta
    tables.pop();

    tables = tables.map(item => `\"${item}\"`);
    const table = tables.join(", ");

    const sql = `TRUNCATE TABLE ${table} RESTART IDENTITY CASCADE`;

    return App.sequelize.query(sql)
      .then(() => {
        return callback();
    }).catch(function() {
        console.log(arguments);
        return callback("fail");
    }.bind(this));
  }

  static dropTables(callback) {
    const tables = this.existingDatabaseTables();

    const dropTable = (table, cb) => {
      const sql = `DROP TABLE IF EXISTS \"${table}\" CASCADE`;
      return App.sequelize.query(sql)
        .then(() => {
          return cb();
      }).catch(function() {
          console.log(arguments);
          return cb("fail");
      }.bind(this));
    };

    return async.eachSeries(tables, dropTable, err => {
      if (err) { console.log(err); }

      return callback();
    });
  }
};
