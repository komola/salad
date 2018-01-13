/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  InstanceMethods: {
    getAssociations() {
      return _.clone(this.eagerlyLoadedAssociations);
    },

    hasAssociation(key) {
      return this.constructor.hasAssociation(key);
    },

    getAssociation(key) {
      return this.constructor.getAssociation(key);
    },

    getAssociationType(key) {
      return this.constructor.getAssociationType(key);
    },

    setAssociation(key, serializedModel) {
      if (!(serializedModel instanceof Array)) {
        serializedModel = [serializedModel];
      }

      // Make sure that the serialized models are all resolved to model instances
      const models = serializedModel.map(model => {
        if (model instanceof Salad.Model) { return model; }
        return this.getAssociation(key).build(model);
      });

      if (this.getAssociationType(key) === "hasMany") {
        return this.eagerlyLoadedAssociations[key] = models;

      } else {
        return this.eagerlyLoadedAssociations[key] = models[0];
      }
    }
  },

  ClassMethods: {
    // register a hasMany association for this mdoel
    // Usage
    //   App.Parent.hasMany App.Children, as: "Children", foreignKey: "parentId"
    hasMany(targetModel, options) {
      // this is the method that we will create in this model
      const getterName = `get${options.as}`;

      // this is the foreignKey field
      const { foreignKey } = options;

      // register the association
      this._registerAssociation(options.as, targetModel, {
        isOwning: false,
        type: "hasMany",
        foreignKey
      }
      );

      // register the method in this model
      // Don't bind to this context, because we want the method to be run in the
      // context of the instance
      return this.prototype[getterName] = function() {
        const conditions = {};
        conditions[foreignKey] = this.get("id");

        const scope = targetModel.scope();

        return scope.where(conditions);
      };
    },

    // register a reverse-association in this model
    belongsTo(targetModel, options) {
      // this is the method that we will create in this model
      const getterName = `get${options.as}`;

      const { foreignKey } = options;

      // register the association
      this._registerAssociation(options.as, targetModel, {
        isOwning: true,
        type: "belongsTo",
        isWeak: options.isWeak,
        foreignKey
      }
      );

      this.attribute(foreignKey);

      // register the method in this model.
      // Don't bind to this context, because we want the method to be run in the
      // context of the instance
      return this.prototype[getterName] = function() {
        const conditions =
          {id: this.get(foreignKey)};

        const scope = targetModel.scope();

        return scope.where(conditions);
      };
    },

    // return the model class for the association key name
    getAssociation(key) {
      key = key[0].toLowerCase() + key.substr(1);
      return this.metadata().associations[key].model;
    },

    getAssociationType(key) {
      key = key[0].toLowerCase() + key.substr(1);
      return this.metadata().associations[key].type;
    },

    getForeignKeys() {
      let foreignKeys = ((() => {
        const result = [];
        const object = this.metadata().associations;
        for (let key in object) {
          const elm = object[key];
          result.push(elm.foreignKey);
        }
        return result;
      })());
      foreignKeys = _.uniq(foreignKeys);

      return foreignKeys;
    },

    hasAssociation(key) {
      key = key[0].toLowerCase() + key.substr(1);
      return this.metadata().associations[key] !== undefined;
    },

    _registerAssociation(as, model, options) {
      let base;
      if (options == null) { options = {}; }
      const key = as[0].toLowerCase() + as.substr(1);

      if (!(base = this.metadata()).associations) { base.associations = {}; }
      this.metadata().associations[key] = {
        as,
        model,
        isOwning: options.isOwning,
        type: options.type,
        isWeak: options.isWeak,
        foreignKey: options.foreignKey
      };

      return true;
    }
  }
};
