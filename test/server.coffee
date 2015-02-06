d = require("domain").create()

# set up error handling to exit with error code on uncaught exceptions
d.on "error", (err) ->
  console.log "Uncaught Exception:", err.message
  console.log err.stack

  process.exit(1)

require "coffee-script/register"
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
    sync.then =>
      cb()

  App.sequelize.query('DROP TABLE "Enums"')
    .then(done)
    .catch(done)

before (done) ->
  @timeout 20000

  # wrap the domain to catch errors
  d.run ->
    Salad.root += "/test"
    Salad.Bootstrap.run
      port: 3001
      env: "test"
      cb: =>
        cleanupDatabase done

beforeEach (done) ->
  @timeout 20000
  cleanupDatabase done

after (done) ->
  Salad.Bootstrap.destroy done
