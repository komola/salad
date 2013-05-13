global.Salad = {}
global.App = global.App || {}
global._ = require "underscore"
global._s = require "underscore.string"

require "./Base"
require "./Bootstrap"
require "./Router"
require "./Controller"
require "./controllers/RestfulController"

require "./Request"

path = process.cwd()
Salad.root = path

module.exports = Salad