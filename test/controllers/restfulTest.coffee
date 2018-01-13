describe "App.RestfulController", ->
  describe "html", ->
    describe "index", ->
      it "renders the index template", (done) ->
        agent.get("http://localhost:3001/todos")
          .end (err, res) ->
            res.ok.should.equal true
            res.text.should.equal "0"

            done()

        return null

    describe "show", ->
      it "returns 404 for non-existent resource", (done) ->
        agent.get("http://localhost:3001/todos/1")
          .end (err, res) ->
            res.notFound.should.equal true

            done()
        return null

    describe "create", ->
      it "creates a model and redirects", (done) ->
        agent.post("http://localhost:3001/todos")
          .send(todo: { title: "New todo"})
          .end (err, res) ->
            res.redirects.length.should.equal 1
            res.text.should.equal "1"

            done()

        return null

      it "accepts form data", (done) ->
        agent.post("http://localhost:3001/todos")
          .send("todo[title]=test")
          .end (err, res) ->
            res.redirects.length.should.equal 1
            res.text.should.equal "1"

            done()

        return null

    describe "update", ->
      it "changes the model and redirects", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.put("http://localhost:3001/todos/1")
            .send(todo: { title: "A"})
            .end (err, res) ->
              res.redirects.length.should.equal 1

              done()
        return null

      it "accepts form data", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.put("http://localhost:3001/todos/1")
            .send("todo[title]=A")
            .end (err, res) ->
              res.redirects.length.should.equal 1

              done()

          return null

      it "returns 404 for non-existent resource", (done) ->
        agent.put("http://localhost:3001/todos/1")
          .send("todo[title]=A")
          .end (err, res) ->
            res.notFound.should.equal true

            done()
        return null


  describe "json", ->
    describe "index", ->
      it "returns collection as array", (done) ->
        agent.get("http://localhost:3001/todos.json")
          .end (err, res) ->
            res.ok.should.equal true
            res.body.length.should.equal 0
            res.type.should.equal("application/json")
            res.charset.should.equal "utf-8"

            done()
        return null

    describe "show", ->
      it "returns 404 for non-existent resource", (done) ->
        agent.get("http://localhost:3001/todos/1.json")
          .end (err, res) ->
            res.notFound.should.equal true

            done()
        return null

      it "returns the resource", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.get("http://localhost:3001/todos/1.json")
            .end (err, res) ->
              res.body.title.should.equal model.get("title")
              res.type.should.equal("application/json")
              res.charset.should.equal "utf-8"

              done()
          return null

    describe "create", ->
      it "returns 201 status code", (done) ->
        agent.post("http://localhost:3001/todos.json")
          .send(todo: { title: "New todo"})
          .end (err, res) ->
            res.status.should.equal 201
            res.body.id.should.equal 1
            res.type.should.equal("application/json")
            res.charset.should.equal "utf-8"

            done()

        return null

      it "returns error message if association does not exist", (done) ->
        agent.post("http://localhost:3001/locations.json")
          .send(location: { title: "New todo", parentId: 999})
          .end (err, res) ->
            res.status.should.equal 400, "correct http status code"
            assert.ok res.body.error

            done()

        return null


    describe "update", ->
      it "changes the model and redirects", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.put("http://localhost:3001/todos/1.json")
            .send(todo: { title: "A"})
            .end (err, res) ->
              res.status.should.equal 200
              res.body.title.should.equal "A"
              res.type.should.equal("application/json")
              res.charset.should.equal "utf-8"

              done()

        return null

      it "returns 404 for non-existent resource", (done) ->
        agent.put("http://localhost:3001/todos/1.json")
          .send(todo: { title: "A"})
          .end (err, res) ->
            res.notFound.should.equal true

            done()

        return null

    describe "destroy", ->
      it "should return the deleted resource", (done) ->
        App.Todo.create title: "Test", (err, model) =>
          agent.del("http://localhost:3001/todos/1.json")
            .end (err, res) ->
              res.ok.should.equal true
              res.statusCode.should.equal 204

              App.Todo.count (err, count) =>
                count.should.equal 0

                done()

        return null
