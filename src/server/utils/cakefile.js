/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {spawn} = require("child_process");
const Table = require("cli-table");
const async = require("async");
const path = require("path");

const Cls = (Salad.Utils.Cakefile = class Cakefile {
  static initClass() {
    this.register = () => {
      Salad.env = process.env.NODE_ENV || "production";
      require(`${Salad.root}/app/config/server/bootstrap`)({run: false});
  
      this.initialized = false;
  
      option("-t", "--title [title]", "Migration title. Usage: cake -t foo db:migrations:create");
      task('db:migrations:create', 'Create a new migration', this.migrationCreate);
  
      task('db:migrations:migrate', 'Migrate the database schema', this.migrate);
  
      task('db:drop', 'Drop the database schema', this.databaseDrop);
  
      task('db:clear', 'Clear the database', this.databaseClear);
  
      task('db:load', 'Load fixtures into the database', this.databaseLoad);
  
      return task('db:statistics', "Shows statistics for the database", this.databaseStatistics);
    };
  
    this.init = cb => {
      if (this.initialized) { return cb(); }
  
      this.initialized = true;
  
      const options = {
        env: Salad.env,
        isCakefile: true
      };
  
      return Salad.Bootstrap.instance().init(options, () => {
        App.sequelize.options.logging = false;
        return cb();
      });
    };
  
  
    this.migrationCreate = options => {
      const name = options.title || "unnamed";
      const command = [".", "node_modules", "sequelize-cli", "bin", "sequelize"].join(path.sep);
      const migrate = spawn(command, ["--coffee",  "--name", name, "migration:create"]);
  
      migrate.stdout.on("data", data => {
        return console.log(data.toString().replace(/\n$/m, ''));
      });
  
      migrate.stderr.on("data", data => {
        return console.log(data.toString().replace(/\n$/m, ''));
      });
  
      return migrate.on("close", () => {
        return console.log("Done");
      });
    };
  
  
    this.migrate = () => {
      const command = [".", "node_modules", "sequelize-cli", "bin", "sequelize"].join(path.sep);
  
      const migrate = spawn(command, ["--coffee", "--env", Salad.env, "db:migrate"]);
  
      migrate.stdout.on("data", data => {
        return console.log(data.toString().replace(/\n$/m, ''));
      });
  
      migrate.stderr.on("data", data => {
        return console.log(data.toString().replace(/\n$/m, ''));
      });
  
      return migrate.on("close", () => {
        return console.log("Done");
      });
    };
  
  
    this.databaseDrop = () => {
      return this.init(() => {
        return Salad.Utils.Models.dropTables(function() {
          console.log("Done!", arguments);
  
          return process.exit();
        }.bind(this));
      });
    };
  
    this.databaseClear = () => {
      return this.init(() => {
        return Salad.Utils.Models.emptyTables(function() {
          console.log("Done!", arguments);
  
          return process.exit();
        }.bind(this));
      });
    };
  
    this.databaseLoad = () => {
      return this.init(() => {
        return Salad.Utils.Models.emptyTables(() => {
          return Salad.Utils.Models.loadFixtures(`${Salad.root}/test/fixtures`, () => {
            console.log("Fixtures loaded");
  
            return process.exit();
          });
        });
      });
    };
  
  
    this.databaseStatistics = () => {
      return this.init(() => {
        let done, iterator;
        const models = Salad.Utils.Models.registered();
        const data = {};
  
        return async.eachSeries(models,
          (iterator = (model, cb) => {
            return model.count((err, count) => {
              data[model.name] = count;
  
              return cb();
            });
          }),
  
          (done = err => {
            const table = new Table({
              head: ["Object", "Amount"]});
  
  
            for (let key in data) {
              const val = data[key];
              table.push([key, val]);
            }
  
            return App.Logger.log(`Object counts:\n${table.toString()}`);
          })
        );
      });
    };
  }
});
Cls.initClass();
