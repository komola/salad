class Salad.Controller extends Salad.Base
  request: null
  response: null
  params: null

_.extend Salad.Controller, require "./mixins/Singleton"