// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  InstanceMethods: {
    takeSnapshot() {
      return this.previousValues = _.clone(this.getAttributes(), true);
    },

    getSnapshot() {
      return this.previousValues || {};
    },

    getChangedAttributes() {
      const changes = {};

      const current = this.getAttributes();
      const previous = this.getSnapshot();

      for (let key in current) {
        const newValue = current[key];
        const oldValue = previous[key];
        if (_.isEqual(newValue, oldValue)) { continue; }

        changes[key] = [oldValue, newValue];
      }

      return changes;
    }
  }
};
