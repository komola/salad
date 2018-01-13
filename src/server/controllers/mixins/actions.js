// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  InstanceMethods: {
    index() {
      return this._index((error, resources) => {
        return this.respondWith({
          html() { return this.render(`${this.resourceOptions.name}/index`, {collection: resources}); },
          json() { return this.render({json: resources}); }
        });
      });
    },

    _index(callback) {
      return this.scoped((err, scope) => {
        return scope.all((err, resources) => {
          this.resources = resources;
          return callback.apply(this, [null, resources]);
      });
    });
    },

    show() {
      return this._show((err, resource) => {
        return this.respondWith({
          html() { return this.render(`${this.resourceOptions.name}/show`, {model: resource}); },
          json() { return this.render({json: resource}); }
        });
      });
    },

    _show(callback) {
      return this.findResource((err, resource) => {
        if (!resource) {
          return this._notFoundHandler();
        }

        this.resource = resource;

        return callback.apply(this, [err, resource]);
    });
    },

    create() {
      return this._create((error, resource) => {
        if ((error != null ? error.isValid : undefined) === false) {
          const errorData = {
            message: (error != null ? error.message : undefined),
            isValid: (error != null ? error.isValid : undefined)
          };

          return this.render({json: {error: errorData}, status: 400});
        }

        return this.respondWith({
          html() {
            const name = _.pluralize(this.resourceOptions.name);
            return this.redirectTo(`/${name}/${resource.get("id")}`);
          },
          json() { return this.render({json: resource, status: 201}); }
        });
      });
    },

    _create(callback) {
      const data = this.params[this.resourceOptions.name];

      return this.scoped((err, scope) => {
        return scope.create(data, (err, resource) => {
          if (err) {
            return callback.apply(this, [err, null]);
          }

          this.resource = resource;

          return callback.apply(this, [null, resource]);
      });
    });
    },

    update() {
      return this._update((error, resource) => {
        if ((error != null ? error.isValid : undefined) === false) {
          return this.render({json: {error}, status: 400});
        }

        return this.respondWith({
          html() {
            const name = _.pluralize(this.resourceOptions.name);
            return this.redirectTo(`/${name}/${resource.get("id")}`);
          },
          json() { return this.render({json: resource, status: 200}); }
        });
      });
    },

    _update(callback) {
      return this.findResource((err, resource) => {
        if (!resource) {
         return this._notFoundHandler();
       }

        const data = this.params[this.resourceOptions.name];
        return resource.updateAttributes(data, (err, resource) => {
          if (err) {
            return callback.apply(this, [err]);
          }

          this.resource = resource;

          return callback.apply(this, [err, resource]);
      });
    });
    },

    destroy() {
      return this._destroy((err, resource) => {
        return resource.destroy(err => {
          return this.respondWith({
            html() {
              const name = _.pluralize(this.resourceOptions.name);
              return this.redirectTo(`/${name}`);
            },
            json() { return this.render({json: {}, status: 204}); }
          });
        });
      });
    },

    _destroy(callback) {
      return this.findResource((err, resource) => {
        if (!resource) {
         return this._notFoundHandler();
       }

        return callback.apply(this, [err, resource]);
    });
    },

    _notFoundHandler() {
      return this.respondWith({
        html: () => this.render("error/404", {status: 404}),
        json: () => this.render({json: {error: "not found"}, status: 404})
      });
    }
  }
};
