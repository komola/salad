/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
global.Sequelize = require("sequelize");
global.async = require("async");
const winston = require("winston");
const findit = require("findit2");
const fs = require("fs");
const gaze = require("gaze");
const path = require("path");
const responseTime = require("response-time");
const cookieParser = require("cookie-parser");
const bodyParser = require("body-parser");
const methodOverride = require("method-override");

const Cls = (Salad.Bootstrap = class Bootstrap extends Salad.Base {
  constructor(...args) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    this.setupHotloadingInFolder = this.setupHotloadingInFolder.bind(this);
    this.start = this.start.bind(this);
    super(...args);
  }

  static initClass() {
    this.extend(require("./mixins/singleton"));
    this.mixin(require("./mixins/metadata"));
    this.mixin(require("./mixins/triggers"));
  
    this.prototype.app = null;
  
    this.prototype.options = {
      routePath: "app/config/server/routes",
      controllerPath: "app/controllers/server",
      mailerPath: "app/mailers",
      modelPath: "app/models/server",
      configPath: "app/config/server/config",
      templatePath: ["app", "templates"].join(path.sep),
      publicPath: "public",
      port: 80,
      env: "production"
    };
  }

  init(options, callback) {
    this.constructor.before("init", this.initConfig);
    this.constructor.before("init", this.initLogger);
    this.constructor.before("init", this.initControllers);
    this.constructor.before("init", this.initMailers);
    this.constructor.before("init", this.initRoutes);
    this.constructor.before("init", this.initHelpers);
    this.constructor.before("init", this.initDatabase);
    this.constructor.before("init", this.initModels);
    this.constructor.before("init", this.initTemplates);
    this.constructor.before("init", this.initExpress);

    this.options.port = options.port || 80;
    this.options.env = (Salad.env = options.env || "production");
    this.options.isCakefile = (Salad.isCakefile = options.isCakefile || false);

    return async.series([
      cb => this.runTriggers("before:init", cb),
      cb => this.runTriggers("after:init", cb)
    ], err => {
      if (err) {
        App.Logger.error(err);
      }

      if (callback) { return callback(err); }
    });
  }

  run(options) {
    return this.init(options, err => {
      if (err) { return; }

      return this.start(options.cb);
    });
  }

  static run(options) {
    if (!options) { options = {}; }

    return Salad.Bootstrap.instance().run(options);
  }

  initConfig(cb) {
    // Salad.Config = require("require-all")
    //   dirname: "#{Salad.root}/#{@options.configPath}"

    // TODO: Allow more than one file and external configuration, i.e.
    // in the /etc folder
    Salad.Config = require(`${Salad.root}/${this.options.configPath}`);

    return cb();
  }

  initLogger(cb) {
    this.metadata().logger = new winston.Logger();
    this.metadata().logger.setLevels(winston.config.syslog.levels);

    this.metadata().logger.add(winston.transports.Console, {
      handleExceptions: false,
      prettyPrint: true,
      colorize: true,
      timestamp: true,
      level: "error"
    }
    );

    App.Logger = this.metadata().logger;

    App.Logger.log = function() {
      for (let key in arguments) {
        const val = arguments[key];
        if (val instanceof Salad.Model) {
          arguments[key] = val.inspect();
        }
      }

      return this.metadata().logger.info.apply(this, arguments);
    }.bind(this);

    App.Logger.error = function() {
      for (let key in arguments) {
        const val = arguments[key];
        if (val instanceof Salad.Model) {
          arguments[key] = val.inspect();
        }
      }

      return this.metadata().logger.error.apply(this, arguments);
    }.bind(this);

    if ((Salad.env !== "test") && !Salad.isCakefile) {
      console.log = App.Logger.log;
      console.error = App.Logger.error;
    }

    return cb();
  }

  initRoutes(cb) {
    require(`${Salad.root}/${this.options.routePath}`);

    return cb();
  }

  // This helps to set up hot loading of changed files
  //
  // It works by deleting the cached require entry for the file and then
  // requiring it again.
  //
  // Afterwards we change the prototype of the old class, so that existing
  // instances get changed, too
  setupHotloadingInFolder(folder, options, callback) {
    if (typeof(options) === "function") {
      callback = options;
      options = {};
    }

    if (!options) { options = {}; }

    return gaze([`${folder}/**/*.coffee`, `${folder}/**/*.js`], (err, watcher) => {
      return watcher.on("changed", file => {
        let oldApp;
        if (options.exclude && (file.indexOf(options.exclude) !== -1)) {
          return;
        }

        console.log("File changed!", file);

        // reload file. Map this in a try block because we are messing with
        // the global App variable
        try {
          // save current global App state in temporary variable
          oldApp = global.App;
          global.App = {};

          delete require.cache[require.resolve(file)];
          require(file);

          // detect which classes where changed. By requiring the file, it gets
          // a new entry in App and we can find out which class was changed
          const changedClasses =  _.keys(global.App);

          // Iterate over all changed classes and detect if a method was deleted.
          for (let newClassName of Array.from(changedClasses)) {
            const oldClass = oldApp[newClassName];
            const newClass = global.App[newClassName];

            let oldMethods = _.keys(oldClass.prototype);
            let newMethods = _.keys(newClass.prototype);

            // If this is the case, delete the method from the existing instances
            for (var currentMethod of Array.from(oldMethods)) {
              // console.log "Deleting instance method #{currentMethod}"
              if (!Array.from(newMethods).includes(currentMethod)) {
                delete oldClass.prototype[currentMethod];
              }
            }

            oldMethods = _.keys(oldClass);
            newMethods = _.keys(newClass);

            // Do the same with static methods
            for (currentMethod of Array.from(oldMethods)) {
              // console.log "Deleting static method #{currentMethod}"
              if (!Array.from(newMethods).includes(currentMethod)) {
                delete oldClass[currentMethod];
              }
            }

            // Replace every old prototype method with the new version
            for (var methodName of Array.from(_.keys(newClass.prototype))) {
              // console.log "Replacing instance method #{methodName}"
              if (typeof(newClass.prototype[methodName]) === "function") {
                oldClass.prototype[methodName] = newClass.prototype[methodName];
              }
            }

            // Do the same with static methods
            for (methodName of Array.from(_.keys(newClass))) {
              // console.log "Replacing static method #{methodName}"
              if (typeof(newClass[methodName]) === "function") {
                oldClass[methodName] = newClass[methodName];
              }
            }
          }

            // FIXME: fat arrow functions don't seem to work.
            // I have no solution how to replace the bound methods, as they
            // are bound per instance when instantiating and I have no way to
            // access every instance
            //
            // Reference: http://stackoverflow.com/a/13687261/9535

          global.App = oldApp;

        } catch (e) {
          global.App = oldApp;
          console.log("Error ocurred. Just reload file");

          delete require.cache[require.resolve(file)];
          require(file);
        }

        if (callback) { return callback(null, file); }
      });
    });
  }


  initControllers(cb) {
    const directory = `${Salad.root}/${this.options.controllerPath}`;
    require("require-all")({
      dirname: directory,
      filter: /\.coffee$/
    });

    if (Salad.env === "development") {
      this.setupHotloadingInFolder(directory);
    }

    return cb();
  }


  initMailers(cb) {
    const directory = `${Salad.root}/${this.options.mailerPath}`;
    require("require-all")({
      dirname: directory,
      filter: /\.coffee$/
    });

    if (Salad.env === "development") {
      this.setupHotloadingInFolder(directory);
    }

    return cb();
  }

  initHelpers(cb) {
    return cb();
  }

  initModels(cb) {
    const directory = `${Salad.root}/${this.options.modelPath}`;
    require("require-all")({
      dirname: directory,
      filter: /\.coffee$/
    });

    if (Salad.env === "development") {
      this.setupHotloadingInFolder(directory);
    }

    return cb();
  }

  initTemplates(callback) {
    // find all templates and save their content in a hash
    const files = [];
    this.metadata().templates = {};

    const dirname = [Salad.root, this.options.templatePath].join(path.sep);

    if (!fs.existsSync(dirname)) {
      throw new Error(`Templates folder does not exist! ${dirname}`);
    }

    const loadTemplateFile = (file, cb) => {
      return fs.readFile(file, (err, content) => {
        if (err) { return cb(err); }

        file = path.normalize(file);
        const index = file
          .replace(path.normalize(dirname), "")
          .replace(/\\/g, "/")
          .replace(/\/(server|shared)\//, "");

        this.metadata().templates[index] = content.toString();

        return cb(err, index);
      });
    };

    async.series([
      cb => {
        const finder = findit(dirname);

        // we received a file
        finder.on("file", (file, stat) => {
          return files.push(file);
        });

        // we received all files.
        return finder.on("end", cb);
      },

      cb => {
        return async.eachSeries(files, loadTemplateFile, cb);
      }
    ], err => {
      return callback(err);
    });

    // watch for changes and automatically reload files
    if (Salad.env === "development") {
      return gaze(`${dirname}/*/*/*.hbs`, (err, watcher) => {
        return watcher.on("changed", file => {
          return loadTemplateFile(file, (err, index) => {
            const content = this.metadata().templates[index];
            Salad.Template.Handlebars.registerPartial(index, content);

            return App.Logger.info(`Template ${index} reloaded`);
          });
        });
      });
    }
  }

  initDatabase(cb) {
    let dbConfig = {
      dialect: "postgres",
      logging: false
    };

    dbConfig = _.extend(dbConfig, Salad.Config.database[Salad.env]);

    // don't pass secret information to the extraConfig object
    const extraConfig = _.omit(dbConfig, "database", "username", "password");
    extraConfig.logging = dbConfig.logging ? console.log : false;

    App.sequelize = new Sequelize(dbConfig.database, dbConfig.username, dbConfig.password,
      extraConfig);

    return cb();
  }

  initExpress(cb) {
    const express = require("express");
    this.metadata().app = express();

    this.metadata().app.use(responseTime());

    // put the static handler before the request logger because we don't want
    // to show all assets. In production environments static assets are probably
    // handled by nginx or something similar anyways
    this.metadata().app.use(express.static(`${Salad.root}/public`));

    if (Salad.env === "development") {
      this.metadata().app.use(express.logger("dev"));

    } else if (Salad.env === "production") {
      this.metadata().app.use(express.logger());
    }

    this.metadata().app.use(cookieParser());
    this.metadata().app.use(bodyParser.urlencoded({extended: false}));
    this.metadata().app.use(bodyParser.json());
    this.metadata().app.use(methodOverride());

    return cb();
  }

  start(callback) {
    return async.series([
      cb => this.runTriggers("before:start", cb),
      cb => {
        const router = new Salad.Router;
        this.metadata().app.all("*", router.dispatch);

        this.metadata().app.use(function(err, req, res, next) {
          console.error(err.stack);

          if (Salad.env === "production") {
            return res.send(500, "Internal server error!");
          } else {
            res.type("text");
            return res.send(500, err.stack);
          }
        });

        this.metadata().expressServer = this.metadata().app.listen(this.options.port);

        if (Salad.env !== "test") { console.log(`Started salad. Environment: ${Salad.env}`); }
        return cb();
      },

      cb => this.runTriggers("after:start", cb)
    ], err => {
      if (callback) { return callback.apply(this); }
    });
  }

  static destroy(callback) {
    return this.instance().destroy(callback);
  }

  destroy(callback) {
    return async.series([
      cb => this.runTriggers("before:destroy", cb),
      cb => {
        this.metadata().expressServer.close(cb);
        return cb();
      },

      cb => this.runTriggers("after:destroy", cb)
    ], err => {
      if (callback) { return callback.apply(this); }
    });
  }
});
Cls.initClass();
