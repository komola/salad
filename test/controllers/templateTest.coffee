describe "Salad.Controller", ->
  it "should not render twice", (done) ->
    agent.get(":3001/rendering/renderTwice")
      .end (err, res) ->
        res.ok.should.equal true

        done()
    return null

  describe "handlebars", ->
    it "renders handlebars template", (done) ->
      agent.get(":3001/rendering/test")
        .then (res) ->
          res.ok.should.equal true
          res.text.should.equal "<h1>Hello World!</h1>"

          return done()

      return null

    it "renders arguments passed to render()", (done) ->
      agent.get(":3001/rendering/arguments")
        .end (err, res) ->
          res.ok.should.equal true

          res.text.should.equal "Hi Seb"

          done()
      return null

    it "wraps output in layout", (done) ->
      agent.get(":3001/rendering/layoutTest")
        .end (err, res) ->
          res.ok.should.equal true

          res.text.should.equal "<body><h1>Hello World!</h1></body>"

          done()
      return null

    it "receives the global env object", (done) ->
      agent.get(":3001/rendering/env")
        .end (err, res) ->
          res.ok.should.equal true
          res.text.should.equal Salad.env
          done()
      return null

    it "supports partials", (done) ->
      agent.get(":3001/rendering/partial")
        .end (err, res) ->
          res.ok.should.equal true
          res.text.should.equal "partial"
          done()
      return null

    it "serializes single models", (done) ->
      App.Todo.create title: "Test", (err, todo) =>
        agent.get(":3001/rendering/show")
          .end (err, res) ->
            res.ok.should.equal true

            res.text.should.equal "<body>#{todo.get("id")}\n</body>"

            done()

      return null

    it "serializes an array of models", (done) ->
      App.Todo.create title: "Test", (err, todo) =>
        agent.get(":3001/rendering/list")
          .end (err, res) ->
            res.ok.should.equal true

            res.text.should.equal "<body>#{todo.get("id")}\n</body>"

            done()

      return null

    it "serializes an array of text", (done) ->
      agent.get(":3001/rendering/array")
        .end (err, res) ->
          res.ok.should.equal true

          res.text.should.equal "<body>1\n</body>"

          done()
      return null


describe "#layout()", ->
  it "sets the layout of the controller", ->
    App.RenderingController.metadata().layout.should.equal "test"

  it "can be set per controller", ->
    App.RenderingController.metadata().layout.should.equal "test"
    App.AnotherLayoutController.metadata().layout.should.equal "foo"

  it "supports partials", (done) ->
    agent.get(":3001/rendering/applicationLayout")
      .end (err, res) ->
        res.ok.should.equal true
        res.text.should.equal """
head
foot
"""
        done()

    return null
