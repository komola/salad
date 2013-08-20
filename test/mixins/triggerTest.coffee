class Foo extends Salad.Base
  @mixin require "../../src/mixins/triggers"
  @mixin require "../../src/mixins/metadata"

  @before "instanceTest", "instanceTestAction"
  instanceTestAction: (done) ->
    @instanceTestActionCalled = true

    done()

  @before "staticTest", "staticTestAction"
  @staticTestAction: (done) ->
    @staticTestActionCalled = true

    done()

  @before "noCallbackTest", "noCallbackAction"
  noCallbackAction: ->
    @noCallbackActionCalled = true

class Parent extends Salad.Base
  @mixin require "../../src/mixins/triggers"
  @mixin require "../../src/mixins/metadata"

  @before "test", ->

class A extends Parent

class B extends Parent

describe "Trigger Mixin", ->
  describe "#runTriggers", ->
    it "resolves string function names when called on an instance", (done) ->
      a = new Foo
      a.runTriggers "before:instanceTest", =>
        assert.isTrue a.instanceTestActionCalled

        done()

    it "resolves string function names when called as a static method", (done) ->
      Foo.runTriggers "before:staticTest", =>
        assert.isTrue Foo.staticTestActionCalled

        done()

    it "finds out if function takes callback or not", (done) ->
      a = new Foo
      a.runTriggers "before:noCallbackTest", =>
        assert.isTrue a.noCallbackActionCalled

        done()

    it "does not interfere with other classes", ->
      A.before "a", ->
      B.before "b", ->
      _.keys(A.metadata().triggerStack).length.should.equal 2
      _.keys(B.metadata().triggerStack).length.should.equal 2
