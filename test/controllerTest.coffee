describe "Controller", ->
  describe "Resources", ->
    describe "#index", ->
      it "should return JSON", (done) ->
        agent.get("http://localhost:3001/locations.json")
          .end (res) ->
            res.ok.should.equal(true)
            res.type.should.equal("application/json")

            done()

      it "has correct content-type header", (done) ->
        agent.get("http://localhost:3001/locations.json")
          .end (res) ->
            res.ok.should.equal(true)
            res.type.should.equal("application/json")
            res.charset.should.equal "utf-8"

            done()

    describe "#create", ->
      it "should return the newly created resource", (done) ->
        agent.post("http://localhost:3001/locations.json")
          .send(location: {title: "Foo", description: "Bar"})
          .end (res) ->
            res.ok.should.equal(true)
            res.body.should.have.property "id"

            done()

      it "should accept form data", (done) ->
        agent.post("http://localhost:3001/locations.json")
          .send("location[title]=Foo")
          .send("location[description]=Bar")
          .end (res) ->
            res.ok.should.equal(true)
            res.body.should.have.property "title"
            res.body.title.should.equal "Foo"

            done()

      it "should accept JSON data", (done) ->
        agent.post("http://localhost:3001/locations.json")
          .send(location: {title: "Foo", description: "Bar"})
          .end (res) ->
            res.ok.should.equal(true)
            res.body.should.have.property "title"
            res.body.title.should.equal "Foo"

            done()

    describe "#show", ->
      it "should return 404 for a non-existent resource", (done) ->
        agent.get("http://localhost:3001/locations/9999.json")
          .end (res) ->
            res.notFound.should.equal true

            done()

      it "should return the resource as json", (done) ->
        App.Location.create title: "Test", (err, resource) ->
          id = resource.get("id")
          agent.get("http://localhost:3001/locations/#{id}.json")
            .end (res) ->
              res.ok.should.equal true
              res.body.should.have.property "title"
              res.body.title.should.equal resource.get("title")

              done()

    describe "#update", ->
      it "should return 404 for a non-existent resource", (done) ->
        agent.put("http://localhost:3001/locations/9999.json")
          .send(title: "Test")
          .end (res) ->
            res.notFound.should.equal true

            done()

      it "should update records", (done) ->
        App.Location.create title: "Test", (err, resource) ->
          id = resource.get("id")
          agent.put("http://localhost:3001/locations/#{id}.json")
            .send(location: title: "Foo")
            .end (res) ->
              res.ok.should.equal true
              res.body.should.have.property "title"
              res.body.title.should.equal "Foo"

              done()

    describe.skip "#destroy", ->
      it "should return 404 for a non-existent resource", (done) ->
        agent.del("http://localhost:3001/locations/9999.json")
          .end (res) ->
            res.notFound.should.equal true

            done()

      it "should return the deleted resource", (done) ->
        App.Location.create title: "Test", (err, resource) ->
          id = resource.get("id")
          agent.del("http://localhost:3001/locations/#{id}.json")
            .end (res) ->
              res.ok.should.equal true
              res.body.should.have.property "title"
              res.body.title.should.equal "Test"

              done()


    describe "#belongsTo", ->
      it "allows nested access", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            agent.get("http://localhost:3001/parent/#{parent.get("id")}/children.json")
              .end (res) ->
                res.ok.should.equal true
                res.body.length.should.equal 1

                done()

      it "returns only associated objects", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            App.Child.create title: "Foobar", (err, child2) ->
              agent.get("http://localhost:3001/parent/#{parent.get("id")}/children.json")
                .end (res) ->
                  res.ok.should.equal true
                  res.body.length.should.equal 1

                  done()

      it "returns empty array for no associated objects", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          agent.get("http://localhost:3001/parent/#{parent.get("id")}/children.json")
            .end (res) ->
              res.ok.should.equal true
              res.body.length.should.equal 0

              done()

      it "still returns all objects for normal index calls", (done) ->
        App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            App.Child.create title: "Foobar", (err, child2) ->
              agent.get("http://localhost:3001/children.json")
                .end (res) ->
                  res.ok.should.equal true
                  res.body.length.should.equal 2

                  done()
