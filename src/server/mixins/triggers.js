// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  InstanceMethods: {
    // resolve this method call to the static method, but pass the current context
    // this way we can reuse the static runTriggers method and don't have to
    // copy it here
    runTriggers(action, callback) {
      return this.constructor.runTriggers.apply(this, [action, callback]);
    }
  },

  ClassMethods: {
    before(method, action) {
      method = `before:${method}`;
      return this._registerTrigger(method, action);
    },

    after(method, action) {
      method = `after:${method}`;
      return this._registerTrigger(method, action);
    },

    _registerTrigger(method, action) {
      let base, base1;
      if (!(base = this.metadata()).triggerStack) { base.triggerStack = {}; }

      const stack = this.metadata().triggerStack;

      if (!(base1 = this.metadata()).triggerStack[method]) { base1.triggerStack[method] = []; }
      return this.metadata().triggerStack[method].push(action);
    },

    runTriggers(action, callback) {
      let base;
      if (!(base = this.metadata()).triggerStack) { base.triggerStack = {}; }
      const stack = this.metadata().triggerStack[action] || [];

      const iterator = (action, cb) => {
        // resolve action if only a string is passed
        if (typeof action === "string") {
          if (!this[action]) {
            throw new Error(`Could not find trigger method ${action}!`);
          }

          action = this[action];
        }

        // does the method accept a callback parameter?
        if (action.length > 0) {
          return action.call(this, cb);

        // if not it is no async method -> call cb() to keep going
        } else {
          action.call(this);
          return cb();
        }
      };

      return async.eachSeries(stack, iterator, callback);
    }
  }
};
