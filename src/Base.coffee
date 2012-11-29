class Salad.Base
  @extend: (name) ->
    _.extend @, require name