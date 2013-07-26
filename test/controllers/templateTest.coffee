describe "#render()", ->
  describe "handlebars", ->
    it "renders handlebars template", (done) ->
      agent.get(":3001/rendering/test")
        .end (res) ->
          res.ok.should.equal true

          res.text.should.equal "<h1>Hello World!</h1>"

          done()

    it "renders arguments passed to render()", (done) ->
      agent.get(":3001/rendering/arguments")
        .end (res) ->
          res.ok.should.equal true

          res.text.should.equal "Hi Seb"

          done()

    it "wraps output in layout", (done) ->
      agent.get(":3001/rendering/layoutTest")
        .end (res) ->
          res.ok.should.equal true

          res.text.should.equal "<body><h1>Hello World!</h1></body>"

          done()

    it "receives the global env object", (done) ->
      agent.get(":3001/rendering/env")
        .end (res) ->
          res.ok.should.equal true
          res.text.should.equal Salad.env
          done()
