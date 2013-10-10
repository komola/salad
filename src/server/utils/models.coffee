fs = require "fs"

Salad.Utils or= {}

class Salad.Utils.Models
  ###
  Returns an array of all available models in the current app.

  This is useful for automatically loading fixtures.

  Usage:
    models = Salad.Utils.Models.registered()
  ###
  @registered: ->
    namespace = App
    models = []

    for modelName, modelClass of App when modelClass.prototype instanceof Salad.Model
      models.push modelClass

    models

  @resolvedRegistered: ->
    models = @registered()

    resolvedDependencies = []
    processed = []

    # build dependency tree
    for model in models
      @_buildDependencyTree model, resolvedDependencies, processed

    resolvedDependencies

  ###
  Return the corresponding database tables of all the models in our app.

  Usage:
    tables = Salad.Utils.existingDatabaseTables()
  ###
  @existingDatabaseTables: ->
    models = @resolvedRegistered()

    tables = (model.daoInstance.daoModelInstance.tableName for model in models)
    tables.push "SequelizeMeta"

    tables

  @loadFixtures: (path, callback) ->
    models = @resolvedRegistered()

    modelToFixtureFile = []

    for model in models
      name = _.pluralize model.name
      name = name.substr(0, 1).toLowerCase() + name.substr(1)

      modelToFixtureFile.push
        name: model.name
        model: model
        file: name

    modelInstances = {}
    fixtureData = {}

    createData = (element, cb) =>
      fixturePath = "#{path}/#{element.file}"

      fs.exists "#{fixturePath}.coffee", (exists) =>
        return cb() unless exists

        data = require fixturePath

        modelCreator = (attributes, _cb) =>
          element.model.create attributes, (err, res) =>
            throw err if err
            modelInstances[element.name] or= []
            modelInstances[element.name].push res

            fixtureData[element.name] or= []
            fixtureData[element.name].push attributes

            _cb err

        async.eachSeries data, modelCreator, cb

    async.eachSeries modelToFixtureFile, createData, (err) =>
      callback err, {instances: modelInstances, data: fixtureData}

  @_buildDependencyTree: (model, resolvedDependencies, processed) ->
    # model was already processed. Skip
    return if model.name in processed

    # get the models association
    associations = model.metadata().associations

    # mark the model as processed
    processed.push model.name

    # iterate over all owning associations
    # owning means, that the association stores the relation information
    # (i.e. has userId column).
    for name, options of associations when options.isOwning
      dependentModel = options.model
      # build the dependency tree for every associated model
      @_buildDependencyTree dependentModel, resolvedDependencies, processed

    resolvedDependencies.push model

  @emptyTables: (callback) ->
    tables = @existingDatabaseTables()

    # remove SequelizeMeta
    tables.pop()

    tables = tables.map (item) -> "\"#{item}\""
    table = tables.join ", "

    sql = "TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE"

    App.sequelize.query(sql)
      .success =>
        callback()
      .error =>
        console.log arguments
        callback "fail"

  @dropTables: (callback) ->
    tables = @existingDatabaseTables()

    dropTable = (table, cb) =>
      sql = "DROP TABLE IF EXISTS \"#{table}\" CASCADE"
      App.sequelize.query(sql)
        .success =>
          cb()
        .error =>
          console.log arguments
          cb "fail"

    async.eachSeries tables, dropTable, (err) =>
      console.log err if err

      callback()
