model = null

describe "Salad.Template", ->
  describe "#render", ->
    it "should render a template", ->
      content = Salad.Template.render "rendering/test"

      content.should.equal "<h1>Hello World!</h1>"

    it "should wrap a template in a layout", ->
      content = Salad.Template.render "rendering/test", layout: "test"

      content.should.equal "<body><h1>Hello World!</h1></body>"

    it "should render partials", ->
      content = Salad.Template.render "rendering/env", layout: "application"

      content.should.equal """head
foot"""

  describe "#serialize", ->
    beforeEach (done) ->
      App.Todo.create title: "Test", (err, todo) ->
        model = todo
        done()

    it "should serialize a normal object", ->
      data =
        key: "value"

      Salad.Template.serialize(data).should.equal data

    it "should serialize a model", ->
      data =
        model: model

      Salad.Template.serialize(data).should.eql
        model: model.toJSON()

    it "should serialize models in an array", ->
      data =
        models: [model]

      Salad.Template.serialize(data).should.eql
        models: [model.toJSON()]

    it "should serialize nested models", ->
      data =
        bootstrap:
          models: [model]

      Salad.Template.serialize(data).should.eql
        bootstrap:
          models: [model.toJSON()]
