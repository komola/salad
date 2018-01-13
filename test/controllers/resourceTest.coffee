describe "App.Controller mixin resource", ->
  describe "#buildConditionsFromParameters", ->
    it "should translate GET parameters to where conditions", ->
      controller = new App.TodosController()
      gtParameters =
        title: "Test"
        createdAt: ">2013-07-15T09:09:09.000Z"

      encodedGtParameters =
        title: "Test"
        createdAt: "%3E2013-07-15T09:09:09.000Z"

      ltParameters =
        title: "Test"
        createdAt: "<2013-07-15T09:09:09.000Z"

      encodedLtParameters =
        title: "Test"
        createdAt: "%3C2013-07-15T09:09:09.000Z"

      shouldGtConditions =
        where:
          title: "Test"
          createdAt: gt: "2013-07-15T09:09:09.000Z"

      shouldLtConditions =
        where:
          title: "Test"
          createdAt: lt: "2013-07-15T09:09:09.000Z"

      conditionsGtHash = controller.buildConditionsFromParameters gtParameters
      conditionsLtHash = controller.buildConditionsFromParameters ltParameters
      encodedGtHash = controller.buildConditionsFromParameters encodedGtParameters
      encodedLtHash = controller.buildConditionsFromParameters encodedLtParameters

      conditionsGtHash.should.eql shouldGtConditions
      conditionsLtHash.should.eql shouldLtConditions

      encodedGtHash.should.eql shouldGtConditions
      encodedLtHash.should.eql shouldLtConditions
      return null

    it "should translate GET parameters to contains conditions", ->
      controller = new App.TodosController()
      parameters =
        title: ":a"

      shouldConditions =
        contains: [title: ["a"]]

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions
      return null

    it "should translate GET parameters to sort conditions", ->
      controller = new App.TodosController()
      parameters =
        sort: "Title,-Name"

      shouldConditions =
        asc: ["Title"]
        desc: ["Name"]

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions
      return null

    it "should translate GET parameters to limit conditions", ->
      controller = new App.TodosController()
      parameters =
        limit: 5000

      shouldConditions =
        limit: "5000"

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions
      return null

    it "should translate GET parameters to offset conditions", ->
      controller = new App.TodosController()
      parameters =
        offset: 5000

      shouldConditions =
        offset: "5000"

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions
      return null

    it "should translate GET parameters to includes", ->
      controller = new App.TodosController()
      parameters =
        includes: "chargingstations,chargingplugs"

      shouldConditions =
        includes: ["chargingstations","chargingplugs"]

      conditionsHash = controller.buildConditionsFromParameters parameters

      conditionsHash.should.eql shouldConditions
      return null

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
      return null

    it "should add contains to scope", ->

      controller = new App.ShopsController()

      shouldConditions =
        contains: ["title": ["a"]]

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()
      secondScope = secondScope.contains "title", "a"

      scope.should.eql secondScope
      return null

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
      return null

    it "should add limit to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        limit: 500

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()
      secondScope = secondScope.limit(500)

      scope.should.eql secondScope
      return null

    it "should add offset to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        offset: 50

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()

      secondScope = secondScope.offset(50)

      scope.should.eql secondScope
      return null

    it "should add includes to scope", ->

      controller = new App.ParentsController()

      shouldConditions =
        includes: ["children"]

      scope = controller.resourceClass()
      scope = controller.applyConditionsToScope(scope,shouldConditions)

      secondScope = controller.resourceClass()

      secondScope = secondScope.includes([App.Child])

      scope.should.eql secondScope
      return null

  describe "#scope", ->
    it "should filter based on where (equality) and ignore unknown attributes", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?title=Hey&asdas=hi")
            .then (res) ->
              res.body.length.should.equal 1
              res.body[0].title.should.equal "Hey"

              done()

    #it "should filter based on array values"
#    it "should filter based on array values", (done) ->
#      return done()
#
#      App.Shop.create title: ['a', 'b', 'c'], (err, model) =>
#        App.Shop.create title: ['d', 'e', 'f'], (err, model) =>
#          App.Shop.create title: ['a', 'g', 'h'], (err, model) =>
#            agent.get(":3001/shops.json?title=:a")
#              .then (err, res) ->
#                res.body.length.should.equal 2
#
#                agent.get(":3001/shops.json?title=:a,b")
#                  .then (err, res) ->
#                    res.body.length.should.equal 1
#
#                    done()

    it "should filter based on where (greather than)", (done) ->

      beforeDate = new Date()
      wait = (time, fun) => setTimeout fun, time
      wait 0, =>
        App.Parent.create title: "Hello", (err1, model1) =>
          App.Parent.create title: "Hey", (err2, model2) =>
            afterDate = new Date()
            agent.get(":3001/parents.json?createdAt=>#{beforeDate.toISOString()}")
              .then (res) ->
                res.body.length.should.equal 2

                agent.get(":3001/parents.json?createdAt=>#{afterDate.toISOString()}")
                  .then (res) ->
                    res.body.length.should.equal 0

                    done()

    it "should filter based on where (less than)", (done) ->

      beforeDate = new Date()
      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          afterDate = new Date()
          agent.get(":3001/parents.json?createdAt=<#{beforeDate.toISOString()}")
            .then (res) ->
              res.body.length.should.equal 0

              agent.get(":3001/parents.json?createdAt=<#{afterDate.toISOString()}")
                .then (res) ->
                  res.body.length.should.equal 2

                  done()

    it "should sort based on sort param", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?sort=-title")
            .then (res) ->
              res.body.length.should.equal 2
              res.body[0].title.should.equal "Hey"

              agent.get(":3001/parents.json?sort=title")
                .then (res) ->
                  res.body.length.should.equal 2
                  res.body[0].title.should.equal "Hello"
                  done()

    it "should limit and offset based on params", (done) ->

      App.Parent.create title: "Hello", (err, model) =>
        App.Parent.create title: "Hey", (err, model) =>
          agent.get(":3001/parents.json?limit=1&offset=0")
            .then (res) ->
              res.body.length.should.equal 1
              res.body[0].title.should.equal "Hello"

              agent.get(":3001/parents.json?offset=1&limit=1")
                .then (res) ->
                  res.body.length.should.equal 1
                  res.body[0].title.should.equal "Hey"
                  done()

    it "should include associated objects based on includes param", (done) ->
      App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            agent.get(":3001/parents.json")
              .then (res) ->
                res.body.length.should.equal 1
                res.body[0].title.should.equal "Parent"

                agent.get(":3001/parents.json?includes=children")
                  .then (res) ->
                    res.body.length.should.equal 1
                    res.body[0].should.have.property "children"

                    done()

    it "should only include objects which are associated", (done) ->
      App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            agent.get(":3001/parents.json")
              .then (res) ->
                res.body.length.should.equal 1
                res.body[0].title.should.equal "Parent"

                agent.get(":3001/parents.json?includes=Todo")
                  .then (res) ->
                    res.body.length.should.equal 1

                    done()

    it "should only include objects which exists", (done) ->
      App.Parent.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) ->
            agent.get(":3001/parents.json")
              .then (res) ->
                res.body.length.should.equal 1
                res.body[0].title.should.equal "Parent"

                agent.get(":3001/parents.json?includes=House")
                  .then (res) ->
                    res.body.length.should.equal 1

                    done()
