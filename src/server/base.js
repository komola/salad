class Salad.Base
  # For static methods
  @extend: (obj) ->
    _.extend @, obj

  # For instance methods
  @include: (obj) ->
    for key, value of obj
      # Assign properties to the prototype
      @::[key] = value

    @

  @mixin: (obj) ->
    @extend obj.ClassMethods if obj.ClassMethods
    @include obj.InstanceMethods if obj.InstanceMethods
