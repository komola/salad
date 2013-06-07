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

before (done) ->
  Salad.root += "/test"
  Salad.Bootstrap.run
    port: 3001
    env: "testing"
    cb: =>
      App.sequelize.sync().done done

beforeEach (done) ->
  sync = App.sequelize.sync(force: true)
  sync.on "success", =>
    done()

after (done) ->
  Salad.Bootstrap.destroy done