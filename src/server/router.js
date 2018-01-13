/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { Router } = require("barista");
const path = require("path");

const router = new Router;

// write our own salad-compatible resource method.
// salad needs routes in this form: resources/:resourceId, barista
// creates them in this format: resources/:id
router.resource = function(path, controller, resourceName) {
  // router.get("/"+controller).to(controller+".index")

  router.get(`/${path}(.:format)`, 'GET').to(controller+'.index');
  router.post(`/${path}(.:format)`, 'POST').to(controller+'.create');
  router.get(`/${path}/add(.:format)`, 'GET').to(controller+'.add');

  router.get(`/${path}/:${resourceName}Id(.:format)`, 'GET').to(controller+'.show');
  router.get(`/${path}/:${resourceName}Id/edit(.:format)`, 'GET').to(controller+'.edit');
  router.put(`/${path}/:${resourceName}Id(.:format)`, 'PUT').to(controller+'.update');
  return router.del(`/${path}/:${resourceName}Id(.:format)`, 'DELETE').to(controller+'.destroy');
};

const Cls = (Salad.Router = class Router extends Salad.Base {
  constructor(...args) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    this.dispatch = this.dispatch.bind(this);
    super(...args);
  }

  static initClass() {
    this.extend(require("./mixins/singleton"));
  }

  // Dispatch the request to the associated controller
  dispatch(request, response) {
    let acceptHeader;
    let requestPath = path.normalize(request.path);

    // remove trailing slashes
    if ((_.last(requestPath) === "/") && (requestPath !== "/")) {
      requestPath = requestPath.substr(0, requestPath.length - 1);
    }

    const matching = this._resolveRoute(requestPath, request);

    // Get the matching controller
    let controllerName = _.capitalize(matching.controller);
    controllerName = `${controllerName}Controller`;
    let controller = this._getMatchingController(controllerName);

    // Could not find associated controller
    if (!controller) {
      if (!App.ErrorContoller) {
        throw new Error("Tried to use App.ErrorController but it does not exist. Please create an ErrorController to show error messages!");
      }
      controller = App.ErrorContoller.instance();
    }

    // Action does not exist in the controller
    if (typeof controller[matching.action] === undefined) {
      controller = App.ErrorController.instance();
      matching.action = 404;
    }

    // Parse Accept header to determine which response format to use
    if (acceptHeader = request.headers.accept) {
      if (acceptHeader.indexOf("application/json") !== -1) {
        matching.format = "json";
      }
    }

    // Pass request and response objects on to the controller instance
    controller.response = response;
    controller.request = request;
    controller.params = _.extend(request.query, request.body, matching);

    // Call the controller action
    return async.series([
        cb => {
          // do not log request information in test
          if (Salad.env === "test") { return cb(); }

          // output dispatching information
          const line = `Dispatching request: ${controllerName}.${matching.action} (${matching.format})`;
          App.Logger.log(line, controller.params);
          return cb();
        },

        cb => controller.runTriggers("beforeAction", cb),
        cb => controller.runTriggers(`before:${matching.action}`, cb),
        cb => {
          // call the action on our controller
          controller[matching.action]();
          return cb();
        },
        // wait for the request to finish, so that we can trigger the after actions
        cb => {
          // don't wait for the render event when the response is already finished
          // this happens when the action does not contain any db calls etc.
          if (response.finished) {
            return cb();
          }

          return controller.on("render", cb);
        },
        cb => controller.runTriggers(`after:${matching.action}`, cb),
        cb => controller.runTriggers("afterAction", cb)
      ],

      // finished dispatching the request
      err => {});
  }

  _resolveRoute(requestPath, request) {
    // Get the first matching route
    let matching = router.first(requestPath, request.method);
    // default format is html"
    if (!matching.format) { matching.format = "html"; }

    // No matching route found
    if (!matching) {
      matching = {
        controller: "error",
        action: 404,
        method: request.method
      };
    }

    return matching;
  }

  _getMatchingController(controllerName) {
    controllerName = _.capitalize(controllerName);
    let controller = App[controllerName];

    if (!controller) {
      throw new Error(`Could not find 'App.${controllerName}'`);
    }

    controller = new controller;

    return controller;
  }

  /*
  Usage:
    Salad.Router.register (router) ->
      router.match("/path").to("controller.action")

  */
  static register(cb) {
    return cb.apply(this.instance(), [router]);
  }
});
Cls.initClass();
