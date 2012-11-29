global.Salad = {}
global.App = global.App || {}
global._ = require "underscore"
global._s = require "underscore.string"

require "./base"
require "./Bootstrap"
require "./router"
require "./controller"
require "./controllers/RestfulController"

require "./Request"

path = process.cwd().split("/")
path = path.join "/"

Salad.root = path

console.log Salad.root


module.exports = Salad