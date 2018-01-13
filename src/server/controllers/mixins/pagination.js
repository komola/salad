/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  ClassMethods: {
    pagination() {
      const _json = this.prototype.json;

      return this.include({
        _index(callback) {
          this.applyPaginationDefaults();

          return this.scoped((err, scope) => {
            scope = scope.limit(this.params.limit).offset(this.params.offset);
            return scope.findAndCountAll((err, result) => {
              this.paginationTotal = result.count;

              return callback.apply(this, [err, result.rows]);
          });
        });
        },

        json(data) {
          if ((this.params.action === "index") && !data.error) {
            data = this._buildPaginationResult(data);
          }

          return _json.call(this, data);
        }
      });
    }
  },

  InstanceMethods: {
    _buildPaginationResult(data) {
      const totalPages = Math.ceil(this.paginationTotal / this.params.limit);
      const currentPage = Math.ceil(this.params.offset / this.params.limit);

      const response = {
        total: this.paginationTotal,
        page: currentPage,
        totalPages,
        limit: this.params.limit,
        offset: this.params.offset,
        items: data
      };

      return response;
    },

    applyPaginationDefaults() {
      if (!this.params.limit) { this.params.limit = 20; }
      this.params.limit = parseInt(this.params.limit, 10);

      if (this.params.limit < 1) {
        this.params.limit = 20;
      }

      if (!this.params.offset) { this.params.offset = 0; }
      this.params.offset = parseInt(this.params.offset, 10);
      if (this.params.offset < 1) {
        return this.params.offset = 0;
      }
    }
  }
};
