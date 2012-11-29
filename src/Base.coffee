class Salad.Base
  # For static methods
  @extend: (name) ->
    _.extend @, require name

  # For instance methods
  @include: (name) ->
    obj = require name

    for key, value of obj
      # Assign properties to the prototype
      @::[key] = value

    @