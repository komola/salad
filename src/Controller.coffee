class Salad.Controller extends Salad.Base
  @extend require "./mixins/Singleton"

  request: null
  response: null
  params: null