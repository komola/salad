// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Cls = (Salad.RestfulController = class RestfulController extends Salad.Controller {
  static initClass() {
    this.mixin(require("./mixins/resource"));
    this.mixin(require("./mixins/actions"));
    this.mixin(require("./mixins/pagination"));
  }

  constructor() {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    this.resourceOptions = this.__proto__.constructor.resourceOptions;
  }
});
Cls.initClass();

