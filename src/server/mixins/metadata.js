/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  InstanceMethods: {
    metadata() {
      if (!this.__proto__.constructor._metadata) { this.__proto__.constructor._metadata = {}; }


      return this.__proto__.constructor._metadata;
    }
  },

  ClassMethods: {
    metadata() {
      if (!this._metadata) { this._metadata = {}; }

      // make sure that we don't have references to the parents
      // metadata object. This would cause triggers and sorts to pile up in every
      // sub-class, leading to trigger actions that can't be found.
      if (this._metadata === this.__super__.constructor._metadata) {
        this._metadata = _.cloneDeep(this.__super__.constructor._metadata, true);
      }

      return this._metadata;
    }
  }
};
