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
  Salad.root += "/test"
  Salad.Bootstrap.run
    port: 3001
    env: "test"
    cb: =>
      cleanupDatabase done

beforeEach (done) ->
  @timeout 20000
  cleanupDatabase done
  return null

after (done) ->
  Salad.Bootstrap.destroy done
