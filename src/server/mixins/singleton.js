/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  _instance: null,

  instance() {
    if (!this._instance) { this._instance = new (this); }

    return this._instance;
  }
};
