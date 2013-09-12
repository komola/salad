describe "App.Controller mixin resource", ->
  describe "#buildConditionsFromParameters", ->
    it "should translate GET parameters to where conditions", ->
      controller = new App.TodosController()
      parameters =
        title: "Test"
        createdAt: ">2013-07-15T09:09:09.000Z"

      shouldConditions =
        where:
          title: "Test"
          createdAt: gt: "2013-07-15T09:09:09.000Z"

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions

    it "should translate GET parameters to sort conditions", ->
      controller = new App.TodosController()
      parameters =
        sort: "Title,-Name"

      shouldConditions =
        asc: ["Title"]
        desc: ["Name"]

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions

    it "should translate GET parameters to limit conditions", ->
      controller = new App.TodosController()
      parameters =
        limit: 5000

      shouldConditions =
        limit: 5000

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions

    it "should translate GET parameters to offset conditions", ->
      controller = new App.TodosController()
      parameters =
        offset: 5000

      shouldConditions =
        offset: 5000

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions

    it "should translate GET parameters to includes", ->
      controller = new App.TodosController()
      parameters =
        includes: "chargingstations,chargingplugs"

      shouldConditions =
        includes: ["chargingstations","chargingplugs"]

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions

  describe "#applyConditionsToScope", ->

    it "should add where to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        where:
          title: "Test"
          createdAt: gt: "2013-07-15T09:09:09.000Z"

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()

      whereConditions =
        title: "Test"
        createdAt: gt: "2013-07-15T09:09:09.000Z"

      secondScope = secondScope.where(whereConditions)

      scope.should.eql secondScope

    it "should add asc and desc to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        asc: ["Title"]
        desc: ["Name"]

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()
      secondScope = secondScope.asc("Title").desc("Name")

      scope.should.eql secondScope

    it "should add limit to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        limit: 500

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()
      secondScope = secondScope.limit(500)

      scope.should.eql secondScope

    it "should add offset to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        offset: 50

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()

      secondScope = secondScope.offset(50)

      scope.should.eql secondScope

    it "should add includes to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        includes: ["Child"]

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()

      secondScope = secondScope.includes([App.Child])

      scope.should.eql secondScope

  describe "#scope", ->
    it "should filter based on where (equality)", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?title=Hey")
            .end (res) ->
              res.body.length.should.equal 1
              res.body[0].title.should.equal "Hey"

              done()

    it "should filter based on where (greather than)", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?createdAt=>1970-01-01T00:00:00.000Z")
            .end (res) ->
              res.body.length.should.equal 2

              done()

    it "should filter based on where (less than)", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?createdAt=<1970-01-01T00:00:00.000Z")
            .end (res) ->
              res.body.length.should.equal 0

              done()

    it "should sort based on sort param", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?sort=-title")
            .end (res) ->
              res.body.length.should.equal 2
              res.body[0].title.should.equal "Hey"

              agent.get(":3001/parents.json?sort=title")
                .end (res) ->
                  res.body.length.should.equal 2
                  res.body[0].title.should.equal "Hello"
                  done()

    it "should limit and offset based on params", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?limit=1&offset=0")
            .end (res) ->
              res.body.length.should.equal 1
              res.body[0].title.should.equal "Hello"

              agent.get(":3001/parents.json?offset=1&limit=1")
                .end (res) ->
                  res.body.length.should.equal 1
                  res.body[0].title.should.equal "Hey"
                  done()

    it "should include associated objects based on includes param", (done) ->
      App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            agent.get(":3001/parents.json")
              .end (res) ->
                res.body.length.should.equal 1
                res.body[0].title.should.equal "Parent"

                agent.get(":3001/parents.json?includes=Child")
                  .end (res) ->
                    res.body.length.should.equal 1

                    done()




















