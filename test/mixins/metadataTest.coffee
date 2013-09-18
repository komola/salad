class Foo extends Salad.Base
  @foo = "test"
  @mixin require "../../src/server/mixins/metadata"

class Bar extends Salad.Base
  @mixin require "../../src/server/mixins/metadata"

describe "Mixins", ->
  describe "metadata", ->
    it "adds @metadata() object to classes", ->
      Foo.metadata().value = "test"
      Bar.metadata().value = "yeah"

      Foo.metadata().value.should.equal "test"
      Bar.metadata().value.should.equal "yeah"

      a = new Foo()
      b = new Bar()

      a.metadata().value.should.equal "test"
      b.metadata().value.should.equal "yeah"
