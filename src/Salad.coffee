global.Salad = {}
global.App = global.App || {}
global._ = require "underscore"
_.mixin require("underscore.string").exports()

require "./Base"
require "./Bootstrap"
require "./Router"
require "./Controller"
require "./controllers/RestfulController"

require "./models/scope"
require "./models/dao"
require "./models/model"

require "./Request"

path = process.cwd()
Salad.root = path

module.exports = Salad