{spawn} = require "child_process"
Table = require "cli-table"
async = require "async"
path = require "path"

class Salad.Utils.Cakefile
  @register: =>
    Salad.env = process.env.NODE_ENV or "production"
    require("#{Salad.root}/app/config/server/bootstrap")(run: false)

    @initialized = false

    option "-t", "--title [title]", "Migration title. Usage: cake -t foo db:migrations:create"
    task 'db:migrations:create', 'Create a new migration', @migrationCreate

    task 'db:migrations:migrate', 'Migrate the database schema', @migrate

    task 'db:drop', 'Drop the database schema', @databaseDrop

    task 'db:clear', 'Clear the database', @databaseClear

    task 'db:load', 'Load fixtures into the database', @databaseLoad

    task 'db:statistics', "Shows statistics for the database", @databaseStatistics

  @init: (cb) =>
    return cb() if @initialized

    @initialized = true

    options =
      env: Salad.env
      isCakefile: true

    Salad.Bootstrap.instance().init options, =>
      App.sequelize.options.logging = false
      cb()


  @migrationCreate: (options) =>
      name = options.title or "unnamed"
      command = [".", "node_modules", "salad", "node_modules", ".bin", "sequelize"].join(path.sep)
      migrate = spawn command, ["--coffee", "-c", name]

      migrate.stdout.on "data", (data) =>
        console.log data.toString().replace(/\n$/m, '')

      migrate.stderr.on "data", (data) =>
        console.log data.toString().replace(/\n$/m, '')

      migrate.on "close", =>
        console.log "Done"


  @migrate: =>
    command = [".", "node_modules", "salad", "node_modules", ".bin", "sequelize"].join(path.sep)

    migrate = spawn command, ["-e", Salad.env, "--coffee", "-m"]

    migrate.stdout.on "data", (data) =>
      console.log data.toString().replace(/\n$/m, '')

    migrate.stderr.on "data", (data) =>
      console.log data.toString().replace(/\n$/m, '')

    migrate.on "close", =>
      console.log "Done"


  @databaseDrop: =>
    @init =>
      Salad.Utils.Models.dropTables =>
        console.log "Done!", arguments

        process.exit()

  @databaseClear: =>
    @init =>
      Salad.Utils.Models.emptyTables =>
        console.log "Done!", arguments

        process.exit()

  @databaseLoad: =>
    @init =>
      Salad.Utils.Models.emptyTables =>
        Salad.Utils.Models.loadFixtures "#{Salad.root}/test/fixtures", =>
          console.log "Fixtures loaded"

          process.exit()


  @databaseStatistics: =>
    @init =>
      models = Salad.Utils.Models.registered()
      data = {}

      async.eachSeries models,
        iterator = (model, cb) =>
          model.count (err, count) =>
            data[model.name] = count

            cb()

        done = (err) =>
          table = new Table
            head: ["Object", "Amount"]


          for key, val of data
            table.push [key, val]

          App.Logger.log "Object counts:\n" + table.toString()
