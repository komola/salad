global.Salad = {}
global.App = global.App || {}
global._ = require "underscore"
_.mixin require("underscore.string").exports()
_.mixin require "underscore.inflections"

require "./base"
require "./bootstrap"
require "./router"
require "./controller"
require "./controllers/restfulController"

require "./models/scope"
require "./models/dao/dao"
require "./models/dao/sequelize"
require "./models/model"

path = process.cwd()
Salad.root = path

module.exports = Salad