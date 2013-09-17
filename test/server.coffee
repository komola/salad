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
  done = =>
    sync = App.sequelize.sync(force: true)
    sync.on "success", =>
      cb()

  App.sequelize.query('DROP TABLE "Enums"')
    .success(done)
    .error(done)

before (done) ->
  @timeout 20000
  Salad.root += "/test"
  Salad.Bootstrap.run
    port: 3001
    env: "testing"
    cb: =>
      cleanupDatabase done

beforeEach (done) ->
  @timeout 20000
  cleanupDatabase done

after (done) ->
  Salad.Bootstrap.destroy done
