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
