/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  ClassMethods: {
    // Add an attribute to this model
    //
    // Possible calls:
    //
    // @attribute "firstname"
    //
    // # Setting the type
    // @attribute "firstname", type: "String"
    attribute(name, options) {
      let base;
      if (!(base = this.metadata()).attributes) { base.attributes = {}; }

      const defaultOptions = {
        name,
        type: "String"
      };

      options = _.extend(defaultOptions, options);

      return this.metadata().attributes[name] = options;
    }
  },

  InstanceMethods: {
    setAttributes(attributes) {
      return (() => {
        const result = [];
        for (let key in attributes) {
          const val = attributes[key];
          if (this.hasAttribute(key)) {
            result.push(this.set(key, val));

          } else if (this.hasAssociation(key)) {
            result.push(this.setAssociation(key, val));
          } else {
            result.push(undefined);
          }
        }
        return result;
      })();
    },

    getDefaultValues() {
      const defaultValues = {};
      const object = this.getAttributeDefinitions();
      for (let key in object) {
        const options = object[key];
        if (options.default !== undefined) {
          defaultValues[key] = options.default;
        }
      }

      return defaultValues;
    },

    // initialize default values
    initDefaultValues() {
      if (this.attributeValues) { return; }

      this.attributeValues = this.getDefaultValues();

      // do not register the default values as changes
      return this.takeSnapshot();
    },

    // check if a model has an attribute
    hasAttribute(key) {
      return (this.metadata().attributes[key] != null);
    },

    getAttributes() {
      this.initDefaultValues();

      return _.clone(this.attributeValues, true);
    },

    getAttributeDefinitions() {
      return this.metadata().attributes;
    },

    set(key, value) {
      this._checkIfKeyExists(key);
      this.initDefaultValues();
      return this.attributeValues[key] = value;
    },

    get(key) {
      this._checkIfKeyExists(key);
      this.initDefaultValues();
      let value = this.attributeValues[key];

      if (value === undefined) {
        value = __guard__(this.getAttributeDefinitions()[key], x => x.defaultValue);
      }

      return value;
    },

    _checkIfKeyExists(key) {
      if (!(key in this.metadata().attributes)) {
        throw new Error(`${key} not existent in ${this}`);
      }
    }
  }
};


function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}