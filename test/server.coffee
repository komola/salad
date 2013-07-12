require "coffee-script"
require "coffee-script-mapped"
require "../"

require "./app/config/server/bootstrap"

global.chai = require "chai"
global.expect = chai.expect
global.assert = chai.assert
global.sinon = require "sinon"
global.async = require "async"
global.agent = require "superagent"

cleanupDatabase = (cb) =>
  App.sequelize.query('DROP TABLE "Enums"')
    .success =>
      sync = App.sequelize.sync(force: true)
      sync.on "success", =>
        cb()

    .error =>
      console.log "Error", arguments

before (done) ->
  Salad.root += "/test"
  Salad.Bootstrap.run
    port: 3001
    env: "testing"
    cb: =>
      cleanupDatabase done

beforeEach (done) ->
  cleanupDatabase done

after (done) ->
  Salad.Bootstrap.destroy done