/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {EventEmitter} = require("events");

const Cls = (Salad.Controller = class Controller extends Salad.Base {
  constructor(...args) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    this.findResource = this.findResource.bind(this);
    super(...args);
  }

  static initClass() {
    this.mixin(require("./mixins/metadata"));
    this.mixin(require("./mixins/triggers"));
    this.mixin(require("./controllers/mixins/renderers"));
    this.include(EventEmitter.prototype);
  
    this.prototype.request = null;
    this.prototype.response = null;
    this.prototype.params = null;
  }

  static beforeAction(callback) {
    return this._registerTrigger("beforeAction", callback);
  }

  static afterAction(callback) {
    return this._registerTrigger("afterAction", callback);
  }

  redirectTo(path) {
    return this.response.redirect(path);
  }

  findResource(id, callback) {
    return this.service.find(id, (err, object) => {
      return callback(err, object);
    });
  }
});
Cls.initClass();
