describe "App.RestfulController", ->
  describe "html", ->
    describe "index", ->
      it "renders the index template", (done) ->
        agent.get(":3001/todos")
          .end (res) ->
            res.ok.should.equal true
            res.text.should.equal "0"

            done()

    describe "show", ->
      it "returns 404 for non-existent resource", (done) ->
        agent.get(":3001/todos/1")
          .end (res) ->
            res.notFound.should.equal true

            done()

    describe "create", ->
      it "creates a model and redirects", (done) ->
        agent.post(":3001/todos")
          .send(todo: { title: "New todo"})
          .end (res) ->
            res.redirects.length.should.equal 1
            res.text.should.equal "1"

            done()

      it "accepts form data", (done) ->
        agent.post(":3001/todos")
          .send("todo[title]=test")
          .end (res) ->
            res.redirects.length.should.equal 1
            res.text.should.equal "1"

            done()

    describe "update", ->
      it "changes the model and redirects", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.put(":3001/todos/1")
            .send(todo: { title: "A"})
            .end (res) ->
              res.redirects.length.should.equal 1

              done()

      it "accepts form data", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.put(":3001/todos/1")
            .send("todo[title]=A")
            .end (res) ->
              res.redirects.length.should.equal 1

              done()

      it "returns 404 for non-existent resource", (done) ->
        agent.put(":3001/todos/1")
          .send("todo[title]=A")
          .end (res) ->
            res.notFound.should.equal true

            done()


  describe "json", ->
    describe "index", ->
      it "returns collection as array", (done) ->
        agent.get(":3001/todos.json")
          .end (res) ->
            res.ok.should.equal true
            res.body.length.should.equal 0
            res.type.should.equal("application/json")
            res.charset.should.equal "utf-8"

            done()

    describe "show", ->
      it "returns 404 for non-existent resource", (done) ->
        agent.get(":3001/todos/1.json")
          .end (res) ->
            res.notFound.should.equal true

            done()

      it "returns the resource", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.get(":3001/todos/1.json")
            .end (res) ->
              res.body.title.should.equal model.get("title")
              res.type.should.equal("application/json")
              res.charset.should.equal "utf-8"

              done()

    describe "create", ->
      it "returns 201 status code", (done) ->
        agent.post(":3001/todos.json")
          .send(todo: { title: "New todo"})
          .end (res) ->
            res.status.should.equal 201
            res.body.id.should.equal 1
            res.type.should.equal("application/json")
            res.charset.should.equal "utf-8"

            done()

      it "returns error message if association does not exist", (done) ->
        agent.post(":3001/locations.json")
          .send(location: { title: "New todo", parentId: 999})
          .end (res) ->
            res.status.should.equal 400, "correct http status code"
            assert.ok res.body.error

            done()


    describe "update", ->
      it "changes the model and redirects", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.put(":3001/todos/1.json")
            .send(todo: { title: "A"})
            .end (res) ->
              res.status.should.equal 200
              res.body.title.should.equal "A"
              res.type.should.equal("application/json")
              res.charset.should.equal "utf-8"

              done()

      it "returns 404 for non-existent resource", (done) ->
        agent.put(":3001/todos/1.json")
          .send(todo: { title: "A"})
          .end (res) ->
            res.notFound.should.equal true

            done()

    describe "destroy", ->
      it "should return the deleted resource", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.del(":3001/todos/1.json")
            .end (res) ->
              res.ok.should.equal true
              res.statusCode.should.equal 204

              App.Todo.count (err, count) =>
                count.should.equal 0

                done()
