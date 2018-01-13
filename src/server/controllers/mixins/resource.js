/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  ClassMethods: {
    resource(options) {
      if (!this.resourceOptions) { this.resourceOptions = {}; }

      if (!options) {
        throw new Error("@resource() can not be called without options!");
      }

      if (typeof(options) === "string") {
        options =
          {name: options};
      }

      const klass = _.capitalize(options.name);

      const defaultOptions = {
        name: options.name,
        resourceClass: klass,
        collectionName: _.pluralize(options.name),
        idParameter: options.name+"Id"
      };

      options = _.extend(defaultOptions, options);

      return this.resourceOptions = options;
    },

    belongsTo(options) {
      if (!this.parentResourceOptions) { this.parentResourceOptions = []; }

      if (!options) {
        if (!this.parentResourceOptions.resourceClass) {
          throw new Error("No resource registered!");
        }

        return App[this.parentResourceOptions.resourceClass];
      }

      if (typeof(options) === "string") {
        options =
          {name: options};
      }

      const klass = _.capitalize(options.name);

      const defaultOptions = {
        name: options.name,
        resourceClass: klass,
        idParameter: options.name+"Id"
      };

      options = _.extend(defaultOptions, options);

      return this.parentResourceOptions.push(options);
    }
  },


  InstanceMethods: {
    findParentRelation() {
      const belongsTo = this.constructor.parentResourceOptions;
      const { params } = this;

      if (!((belongsTo != null ? belongsTo.length : undefined) > 0)) {
        return null;
      }

      for (let relation of Array.from(belongsTo)) {
        if (params.hasOwnProperty(relation.idParameter)) {
          return relation;
        }
      }

      return null;
    },

    parentResource() {
      const relation = this.findParentRelation();

      if (!relation) {
        return false;
      }

      return App[relation.resourceClass];
    },

    findParent(callback) {
      const parent = this.parentResource();
      const relation = this.findParentRelation();

      if (!parent) {
        if (callback) { return callback.call(this, null, false); }
        return false;
      }

      parent.find(this.params[relation.idParameter], (err, parent) => {
        this.parent = parent;
        if (callback) { return callback.call(this, err, parent); }
      });

      return false;
    },

    resourceClass() {
      if (!(this.resourceOptions != null ? this.resourceOptions.resourceClass : undefined)) {
        throw new Error("No resource registered!");
      }

      return App[this.resourceOptions.resourceClass];
    },

    findResource(callback) {
      const paramKey = this.resourceOptions.idParameter;
      return this.scoped((err, scope) => {
        return scope.find(this.params[paramKey], (err, resource) => {
          if (err) {
            return callback.apply(this, [error]);
          }

          return callback.apply(this, [null, resource]);
      });
    });
    },

    scoped(callback) {
      return this.findParent((err, parent) => {
        let scope;
        if (parent) {
          const collectionGetter = `get${_.capitalize(this.resourceOptions.collectionName)}`;
          scope = parent[collectionGetter]();

        } else {
          scope = this.resourceClass();
        }

        const conditions = this.buildConditionsFromParameters(this.params);

        scope = this.applyConditionsToScope(scope, conditions);

        return callback.call(this, null, scope);
      });
    },

    /*
      This builds conditions by URL params. Possible condtions are:
        Where:
          Equality:
            ?title=Dishes
          Greater than:
            ?createdAt=>2013-07-15T09:09:09.000Z
          Less than:
            ?createdAt=<2013-07-15T09:09:09.000Z
        Sorting:
          ?sort=createdAt,-title

          This would sort ascending by createdAt and descending by title. Ascending is assumed by default
    */
    buildConditionsFromParameters(parameters) {
      // Some parameter names are reserved and have a special meaning
      const reservedParams = ["sort","include","includes","limit","offset","method","controller","action","format"];

      // only accept parameters that represent an attribute for where conditions
      const allowedWhereAttributes = _.keys(App[this.resourceOptions.resourceClass].metadata().attributes);

      let conditions = {};

      for (let key in parameters) {
        // check if the parameter name needs special handling
        let value = parameters[key];
        value = decodeURIComponent(value);

        if (Array.from(reservedParams).includes(key)) {
          if (key === "sort") {
            conditions = this._buildSortConditions(value, conditions);
          }

          if ((key === "limit") || (key === "offset")) {
            // limit and offset are simple params
            conditions[key] = value;
          }

          if (key === "includes") {
            conditions = this._buildIncludesConditions(value, conditions);
          }

          continue;
        }

        if (!Array.from(allowedWhereAttributes).includes(key)) {
          continue;
        }
        // all other parameter names are treated as where conditions
        conditions = this._buildFilterConditions(key, value, conditions);
      }

      return conditions;
    },

    _buildSortConditions(paramValue, conditions) {
      // sorting supports multiple attributes to sort by
      const sortParams = paramValue.split(",");

      for (let value of Array.from(sortParams)) {
        const firstChar = value[0];
        // we sort ascending by default
        // a minus in front of the attribute sorts descending
        if (firstChar !== "-") {
          if (!conditions.asc) { conditions.asc = []; }
          conditions.asc.push(value);
        } else if (firstChar === "-") {
          if (!conditions.desc) { conditions.desc = []; }
          conditions.desc.push(value.slice(1));
        }
      }
      return conditions;
    },

    _buildIncludesConditions(paramValue, conditions) {
      // includes can contain multiple classes

      const includeParams = paramValue.split(",");
      for (let value of Array.from(includeParams)) {
        if (!conditions.includes) { conditions.includes = []; }
        conditions.includes.push(value);
      }

      return conditions;
    },

    _buildFilterConditions(key, value, conditions) {
      if (!conditions.where) { conditions.where = {}; }
      if (!conditions.contains) { conditions.contains = []; }
      const firstChar = value[0];
      const checksForEquality = ![">", "<", ":"].includes(firstChar);
      if (!checksForEquality) {
        if (firstChar === ":") {
          const holder = {};
          if (!holder[key]) { holder[key] = []; }
          const filterParams = value.slice(1).split(",");
          for (let param of Array.from(filterParams)) {
            holder[key].push(param);
          }
          conditions.contains.push(holder);
        } else {
          let bindingElm;
          if (firstChar === ">") {
            // we search values which are greater as the specified value
            bindingElm = "gt";
          } else if (firstChar === "<") {
            bindingElm = "lt";
          }

          conditions.where[key] = {};
          conditions.where[key][bindingElm] = value.slice(1);
        }
      } else {
        conditions.where[key] = value;
      }

      for (key in conditions) {
        const val = conditions[key];
        if (_.isEmpty(val)) {
          delete conditions[key];
        }
      }

      return conditions;
    },

    applyConditionsToScope(scope, conditions) {
      // some conditions do not need special handling
      const simpleKeys = ["limit","offset","where"];

      for (let key in conditions) {
        // iterate by key over the conditions object
        let value = conditions[key];
        if (!Array.from(simpleKeys).includes(key)) {
          // includes, asc and desc need special handling
          // includes takes an array as parameter
          const includesClassArray = [];

          for (value of Array.from(conditions[key])) {
            if (key === "includes") {
              // the param is a string, from which we need to construct the class name
              const { associations } = App[this.resourceOptions.resourceClass].metadata();
              const theClass = associations[value] != null ? associations[value].model : undefined;
              if (theClass) {
                includesClassArray.push(theClass);
              }
              scope = scope.includes(includesClassArray);
            }

            if (key === "asc") {
              scope = scope.asc(value);
            }

            if (key === "desc") {
              scope = scope.desc(value);
            }

            if (key === "contains") {
              for (let containKey in value) {
                const paramArray = value[containKey];
                for (let param of Array.from(paramArray)) {
                  scope = scope.contains(containKey, param);
                }
              }
            }
          }



        } else {
          // apply calls the method key on the object scope with the values given in the array
          scope = scope[key].apply(scope,[value]);
        }
      }

      // return the scope, so it can be used
      return scope;
    }
  }
};
