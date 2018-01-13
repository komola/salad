describe "Controller", ->
  describe "Resources", ->
    describe "#belongsTo", ->
      it "allows nested access", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            agent.get("http://localhost:3001/parent/#{parent.get("id")}/children.json")
              .then (res) ->
                res.ok.should.equal true
                res.body.length.should.equal 1

                done()

      it "returns only associated objects", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            App.Child.create title: "Foobar", (err, child2) ->
              agent.get("http://localhost:3001/parent/#{parent.get("id")}/children.json")
                .then (res) ->
                  res.ok.should.equal true
                  res.body.length.should.equal 1

                  done()

      it "returns empty array for no associated objects", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          agent.get("http://localhost:3001/parent/#{parent.get("id")}/children.json")
            .then (res) ->
              res.ok.should.equal true
              res.body.length.should.equal 0

              done()

      it "still returns all objects for normal index calls", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            App.Child.create title: "Foobar", (err, child2) ->
              agent.get("http://localhost:3001/children.json")
                .then (res) ->
                  res.ok.should.equal true
                  res.body.length.should.equal 2

                  done()

  describe "Performance", ->
    it "can handle two simultaneous requests", (done) ->
      async.parallel
        one: (cb) ->
          agent.get(":3001/performance?param=1")
            .then (res) ->
              res.ok.should.equal true
              # res.text.should.equal 1

              cb()

        two: (cb) ->
          agent.get(":3001/performance?param=2")
            .then (res) ->
              res.ok.should.equal true
              # res.text.should.equal 2

              cb()


        finished = (err) =>
          done()
