describe "Salad.Model", ->
  describe "DAO", ->
    describe "#create", ->
      res = null
      params =
        title: "Test"
        description: "Description"

      beforeEach (done) ->
        App.Location.create params, (err, resource) =>
          res = resource
          done()

      it "returns a Salad.Model instance", (done) ->
        assert.ok res
        assert.isTrue res instanceof App.Location, "resource instanceof App.Location"

        done()

      it "saves the item in the database", (done) ->
        res.get("id").should.equal 1
        res.get("title").should.equal params.title
        res.get("description").should.equal params.description

        done()

      it "supports many instances", (done) ->
        res.get("id").should.equal 1

        App.Location.create title: "A", (err, a) ->
          res.get("id").should.equal 1
          a.get("id").should.equal 2

          App.Location.create title: "B", (err, b) =>
            a.get("id").should.equal 2
            b.get("id").should.equal 3

            done()

      it "supports enum values", (done) ->
        App.Enum.create title: "A", (err, resource) =>
          resource.get("title").should.equal "A"

          App.Enum.first (err, resource2) =>
            resource2.get("title").should.equal "A"

            done()

      it "sets the id of the creating instance", (done) ->
        location = App.Location.build title: "Test"

        location.save (err, newLocation) ->
          assert.ok location.get("id")

          done()

      # TODO See https://github.com/sequelize/sequelize/issues/815
      it.skip "does not break when id is set to null", (done) ->
        attribs =
          title: "Test"
        App.Todo.create attribs, (err, resource) =>
          assert.ok resource.get("id")

          done()

      it "applies default values", (done) ->
        App.Todo.create title: "test", (err, todo) ->
          assert.ok todo

          assert.isTrue todo.get("isDone") isnt null
          todo.get("isDone").should.equal false

          done()

    describe "#updateAttributes", ->
      res = null
      params =
        title: "Test"
        description: "Description"

      beforeEach (done) ->
        App.Location.create params, (err, resource) =>
          resource.updateAttributes title: "Foo", (err, resource) =>
            res = resource
            done()

      it "returns a Salad.Model instance", (done) ->
        assert.ok res
        assert.isTrue res instanceof App.Location, "resource instanceof App.Location"

        done()

      it "saves the item in the database", (done) ->
        res.get("id").should.equal 1
        res.get("title").should.equal "Foo"
        res.get("description").should.equal params.description

        done()

      it "can set attributes to null values", (done) ->
        res.get("title").should.equal "Foo"

        res.updateAttributes title: null, (err, newResource) ->
          assert.equal newResource.get("title"), null

          done()

      it "can change default values", (done) ->
        App.Todo.create title: "test", (err, todo) ->
          assert.ok todo

          todo.get("isDone").should.equal false

          todo.set "isDone", true

          todo.save (err, newTodo) ->
            newTodo.get("isDone").should.equal true

            done()

    describe "#save", ->
      it "creates a record when it is new", (done) ->
        resource = App.Location.build title: "Test"

        resource.get("title").should.equal "Test"

        assert.isTrue resource.isNew

        resource.save (err, res) =>
          assert.ok res
          assert.ok res.get("id")

          res.isNew.should.equal false

          res.get("title").should.equal resource.get("title")
          done()

      it "updates a record when it is not new", (done) ->
        App.Location.create title: "Test", (err, res) =>

          res.set "title", "Foo"
          res.save (err, res) =>
            assert.ok res
            assert.ok res.get("id")
            res.isNew.should.equal false

            res.get("title").should.equal "Foo"

            done()

      it "changes the isNew attribute on save", (done) ->
        location = App.Location.build title: "Test"
        assert.isTrue location.isNew

        location.save (err, res) ->
          assert.isFalse location.isNew

          done()

    describe "#destroy", ->
      it "destroys the model", (done) ->
        App.Location.create title: "Test", (err, res) ->
          res.destroy =>
            App.Location.count (err, count) =>
              count.should.equal 0

              done()

      it "destroys all created models", (done) ->
        App.Location.create title: "Test", (err, res) ->
          App.Location.destroy =>
            App.Location.count (err, count) =>
              count.should.equal 0

              done()

      it "accepts conditions for destroy", (done) ->
        App.Location.create title: "A", ->
          App.Location.create title: "B", ->
            App.Location.where(title: "A").destroy ->
              App.Location.count (err, count) =>
                count.should.equal 1

                done()

    describe "#increment", ->
      model = null

      beforeEach (done) ->
        App.Todo.create title: "test", (err, todo) =>
          model = todo

          done()

      it "increases the value of a field by the specified amount", (done) ->
        model.get("counter").should.equal 0

        model.increment "counter", 3, =>
          model.get("counter").should.equal 3
          App.Todo.find model.get("id"), (err, resource) =>
            resource.get("counter").should.equal 3

            done()

      it "increases the value by 1 if no value is specified", (done) ->
        model.get("counter").should.equal 0

        model.increment "counter", =>
          model.get("counter").should.equal 1
          App.Todo.find model.get("id"), (err, resource) =>
            resource.get("counter").should.equal 1

            done()

      it "accepts an object of fields", (done) ->
        model.get("counter").should.equal 0
        model.get("counterB").should.equal 0

        model.increment counter: 1, counterB: 3, =>
          model.get("counter").should.equal 1
          model.get("counterB").should.equal 3
          App.Todo.find model.get("id"), (err, resource) =>
            resource.get("counter").should.equal 1
            resource.get("counterB").should.equal 3

            done()



      it "should not run into concurrency issues", (done) ->
        async.parallel [
          (cb) => model.increment "counter", 1, cb
          (cb) => model.increment "counter", 2, cb
          (cb) => model.increment "counter", 3, cb
          (cb) => model.increment "counter", 4, cb
          (cb) => model.increment "counter", 5, cb
        ], (err) =>
          App.Todo.find model.get("id"), (err, resource) =>
            resource.get("counter").should.equal 15

            done()

    describe "#decrement", ->
      model = null

      beforeEach (done) ->
        App.Todo.create title: "test", counter: 4, counterB: 3, (err, todo) =>
          model = todo

          done()

      it "increases the value of a field by the specified amount", (done) ->
        model.get("counter").should.equal 4

        model.decrement "counter", 3, =>
          model.get("counter").should.equal 1
          App.Todo.find model.get("id"), (err, resource) =>
            resource.get("counter").should.equal 1

            done()

      it "increases the value by 1 if no value is specified", (done) ->
        model.get("counter").should.equal 4

        model.decrement "counter", =>
          model.get("counter").should.equal 3
          App.Todo.find model.get("id"), (err, resource) =>
            resource.get("counter").should.equal 3

            done()

      it "accepts an object of fields", (done) ->
        model.get("counter").should.equal 4
        model.get("counterB").should.equal 3

        model.decrement counter: 1, counterB: 3, =>
          model.get("counter").should.equal 3
          model.get("counterB").should.equal 0
          App.Todo.find model.get("id"), (err, resource) =>
            resource.get("counter").should.equal 3
            resource.get("counterB").should.equal 0

            done()

  describe "attributes", ->
    describe "#set", ->
      it "sets an attribute to a specific value", ->
        location = App.Location.build title: "Test"
        location.set "title", "Foo"

        location.get("title").should.equal "Foo"

    describe "#get", ->
      it "returns an attribute", ->
        location = App.Location.build title: "Test"
        location.get("title").should.equal "Test"

    describe "#setAttributes", ->
      it "sets attributes of a model", ->
        location = App.Location.build()
        location.setAttributes
          title: "Test"

        location.get("title").should.equal "Test"

      it "only sets existent attributes", ->
        location = App.Location.build()
        location.setAttributes
          title: "Test"
          foo: "bar"

        location.get("title").should.equal "Test"

      it "applies eagerlyLoadedAssociations for belongsTo", ->
        data =
          title: "Test"
          operator:
            title: "FooOperator"

        location = App.Location.build data

        assert.ok location.eagerlyLoadedAssociations.operator
        assert.isTrue location.eagerlyLoadedAssociations.operator instanceof App.Operator

      it "applies eagerlyLoadedAssociations for hasMany", ->
        data =
          title: "Test"
          children:
            [
              title: "Foo"
            ]

        location = App.Location.build data

        assert.ok location.eagerlyLoadedAssociations.children
        assert.ok location.eagerlyLoadedAssociations.children.length
        assert.isTrue location.eagerlyLoadedAssociations.children[0] instanceof App.Location

  describe "associations", ->
    describe "#hasMany", ->
      it "creates getter method", ->
        model = App.Location.build title: "test"

        assert.ok model.getChildren

      it "adds the correct conditions", ->
        model = App.Location.build title: "test", id: 1

        scope = model.getChildren()

        assert.ok scope.data.conditions
        assert.ok scope.data.conditions.parentId
        scope.data.conditions.parentId.should.equal 1

      it "returns the correct object", (done) ->
        App.Location.create title: "Parent", (err, parent) ->
          parent.get("id").should.equal 1, "parent has id 1"

          App.Location.create title: "Child", parentId: parent.get("id"), (err, child) ->
            child.get("id").should.equal 2, "child has id 2"

            scope = parent.getChildren()

            scope.data.conditions.parentId.should.equal 1, "scope has the correct parentId condition"

            scope.all (err, resources) =>
              assert.ok resources, "returned array of resources"

              resources.length.should.equal 1, "returned 1 resource"
              resources[0].get("id").should.equal child.get("id"), "resource id matches child id"

              done()

    describe "#belongsTo", ->
      it "creates getter method", ->
        model = App.Location.build title: "test"

        assert.ok model.getParent

      it "adds the correct conditions", ->
        model = App.Location.build title: "test", parentId: 1

        scope = model.getParent()

        assert.ok scope.data.conditions
        assert.ok scope.data.conditions.id

        _.keys(scope.data.conditions).length.should.equal 1

        scope.data.conditions.id.should.equal 1

      it "returns the correct object", (done) ->
        App.Location.create title: "Parent", (err, parent) ->
          parent.get("id").should.equal 1, "parent has id 1"

          App.Location.create title: "Child", parentId: parent.get("id"), (err, child) ->
            child.get("id").should.equal 2, "child has id 2"

            scope = child.getParent()

            scope.all (err, res) ->
              assert.ok res

              res[0].get("id").should.equal parent.get("id")

              done()

      it "accepts additional conditions in the scope", (done) ->
        App.Location.create title: "Parent", (err, parent) ->
          parent.get("id").should.equal 1, "parent has id 1"

          App.Location.create title: "Child", parentId: parent.get("id"), (err, child) ->
            child.get("id").should.equal 2, "child has id 2"

            scope = child.getParent().where(title: "Parent")

            scope.all (err, res) ->
              assert.ok res

              res.length.should.equal 1

              res[0].get("id").should.equal parent.get("id")

              done()

    describe "#hasAssociation", ->
      it "should return true for existing associations", ->
        App.Location.hasAssociation("operator").should.equal true
        location = App.Location.build(title: "Test")
        location.hasAssociation("operator").should.equal true

      it "should return false for non-existing associations", ->
        App.Location.hasAssociation("foo").should.equal false
        location = App.Location.build(title: "Test")
        location.hasAssociation("foo").should.equal false

  describe "scope", ->
    it "accepts chained conditions", ->
      scope = App.Location.where(title: "Test").asc("title").limit(3)

      _.keys(scope.data.conditions).length.should.equal 1
      scope.data.order.length.should.equal 1
      scope.data.limit.should.equal 3

    it "does not interfere with other scopes", ->
      scope = new Salad.Scope(daoInstance: undefined)
      scope.where(field: "Test")

      _.keys(scope.data.conditions).length.should.equal 1

      newScope = new Salad.Scope(daoInstance: undefined)
      newScope.limit(3)

      assert.isFalse scope is newScope

      _.keys(newScope.data.conditions).length.should.equal 0


      newScope.data.limit.should.equal 3
      _.keys(scope.data.conditions).length.should.equal 1, "first scope remains untouched"

    describe "#create", ->
      it "creates an object with association information", (done) ->
        App.Location.create title: "Parent", (err, resource) =>
          resource.getChildren().create title: "Child", (err, child) =>
            assert.ok child
            child.get("id").should.equal 2
            child.get("parentId").should.equal 1

            done()

    describe "#count", ->
      it "returns the correct count", (done) ->
        App.Location.create title: "Test", (err, res) =>
          App.Location.count (err, count) =>
            count.should.equal 1

            done()

      it "does not cause error with orderBy statements", (done) ->
        App.Location.create title: "Test", (err, res) =>
          App.Location.desc("createdAt").count (err, count) =>
            count.should.equal 1

            done()


    describe "#build", ->
      it "creates an instance with association information", (done) ->
        App.Location.create title: "Parent", (err, resource) =>
          child = resource.getChildren().build title: "Child"

          child.get("parentId").should.equal 1

          done()

      it "applies default values", (done) ->
        todo = App.Todo.build title: "test"

        assert.ok todo

        assert.isTrue todo.get("isDone") isnt null
        todo.get("isDone").should.equal false

        done()


    describe "#nil", ->
      beforeEach (done) ->
        App.Location.create title: "Parent", (err, resource) =>
          done()

      it "returns undefined on #first", (done) ->
          App.Location.nil().first (err, res) ->
            assert.isUndefined res
            done()

      it "returns empty array on #all", (done) ->
          App.Location.nil().all (err, res) ->
            res.length.should.equal 0

            App.Location.all (err, res) ->
              res.length.should.equal 1
              done()

      it "returns undefined un #find", (done) ->
          App.Location.nil().find 1, (err, res) ->
            assert.isUndefined res

            App.Location.find 1, (err, res) ->
              assert.ok res
              done()

    describe "#remove", ->
      it "removes the association but does not delete the object", (done) ->
        App.Location.create title: "Parent", (err, parent) =>
          parent.getChildren().create title: "Child", (err, child) =>
            child.get("parentId").should.equal parent.get("id")

            parent.getChildren().remove child, (err) =>
              App.Location.find child.get("id"), (err, newChildObject) =>
                assert.equal newChildObject.get("parentId"), null

                done()


    describe "#includes", ->
      it "eager-loads one associated objects", (done) ->
        App.Operator.create title: "Operator", (err, operator) =>
          operator.getLocations().create title: "Location", (err, location) =>
            App.Location.includes([App.Operator]).all (err, locations) =>

              locations.length.should.equal 1
              _.keys(locations[0].getAssociations()).length.should.equal 1
              locations[0].getAssociations().operator.get("id").should.equal operator.get("id")

              assert.isDefined locations[0].toJSON().operator
              locations[0].toJSON().operator.id.should.equal operator.get("id")

              done()

      it "eager-loads many associated objects", (done) ->
        App.Operator.create title: "Operator", (err, operator) =>
          operator.getLocations().create title: "Location", (err, location) =>
            App.Operator.includes([App.Location]).all (err, operators) =>

              operators.length.should.equal 1
              _.keys(operators[0].getAssociations()).length.should.equal 1
              operators[0].getAssociations().locations[0].get("id").should.equal location.get("id")

              data = operators[0].toJSON()

              assert.isTrue data.locations instanceof Array

              data.locations.length.should.equal 1


              done()

      it "preserves desired naming when eager-loading", (done) ->
        App.Operator.create title: "Operator", (err, operator) =>
          operator.getOperatorItems().create data: "test", (err, location) =>
            App.Operator.includes([App.OperatorItem]).all (err, operators) =>
              data = (a.toJSON() for a in operators)

              data[0].should.have.property "operatorItems"

              done()

      it "accepts strings for named field parameters", (done) ->
        App.Operator.create title: "Operator", (err, operator) =>
          operator.getOperatorItems().create data: "test", (err, location) =>
            App.Operator.includes(["OperatorItems"]).all (err, operators) =>
              data = (a.toJSON() for a in operators)

              data[0].should.have.property "operatorItems"

              done()

      it "can load the correct association when there are more than one", (done) ->
        App.Operator.create title: "OperatorA", (err, operatorA) =>
          App.Operator.create title: "OperatorB", (err, operatorB) =>
            data =
              title: "test"
              support_operatorId: operatorB.get("id")
              operatorId: operatorA.get("id")

            App.Location.create data, (err, location) =>
              App.Location.includes(["SupportOperator", "Operator"]).all (err, locations) =>
                data = (a.toJSON() for a in locations)

                data[0].should.have.property "supportOperator"
                data[0].should.have.property "operator"

                data[0].supportOperator.id.should.equal operatorB.get("id")
                data[0].operator.id.should.equal operatorA.get("id")

                done()

    describe "#where", ->
      it "accepts normal fields", (done) ->
        App.Shop.create otherField: "Test", (err, resource) ->
          App.Shop.where(otherField: "Test").all (err, resource) ->
            resource.length.should.equal 1

            done()

    describe "#contains", ->
      it "searches in array fields", (done) ->
        App.Shop.create title: ["A", "B"], (err, resource) ->
          resource.set "title", ["A", "B", "C"]
          resource.save =>
            App.Shop.contains("title", "A").all (err, resources) =>
              resources.length.should.equal 1
              done()

      it "should prohibit ambiguity", (done) ->
        App.Parent.create title: "Parent", otherTitle: ["Peter", "Alex"], (err, parent) =>
          parent.getChildren().create title: "Child", otherTitle: ["Hans", "Max"], (err, child) =>
            App.Parent.includes([App.Child]).contains("otherTitle", "Peter").all (err, resources) =>
              resources.length.should.equal 1
              done()


      it "allows camelCase in field title", (done) ->
        App.Shop.create anotherTitle: ["A", "B"], (err, resource) ->
          resource.set "anotherTitle", ["A", "B", "C"]
          resource.save =>
            App.Shop.contains("anotherTitle", "A").all (err, resources) =>
              resources.length.should.equal 1
              done()

      it "works along where queries", (done) ->
        params =
          title: ["A", "B"]
          otherField: "Bar"

        App.Shop.create params, (err, resource) ->
          App.Shop.where("otherField": "ASD").contains("title", "A").all (err, resources) =>
            resources.length.should.equal 0
            done()

    describe "trigger", ->
      beforeEach ->
        App.Shop.metadata().triggerStack = {}

      it "is registered on the static model", (done) ->
        App.Shop.before "create", (cb) =>
          cb()

        assert.ok App.Shop.metadata().triggerStack["before:create"]
        assert.ok App.Shop.metadata().triggerStack["before:create"].length > 0

        done()

      it "can be triggered statically", (done) ->
        beforeFired = false
        afterFired = false

        App.Shop.before "create", (cb) =>
          afterFired.should.equal false
          beforeFired = true
          cb()

        App.Shop.after "create", (cb) =>
          beforeFired.should.equal true
          afterFired = true
          cb()

        App.Shop.create title: ["test"], (err, resource) =>
          afterFired.should.equal true
          beforeFired.should.equal true
          done()

      it "gives the context of the resource", (done) ->
        App.Shop.after "create", (cb) ->
          @get("id").should.equal 1

          cb()

        App.Shop.create title: ["test"], (err, resource) =>
          done()

      it "is triggered on save", (done) ->
        triggered = false

        App.Shop.after "save", (cb) ->
          triggered = true
          cb()

        App.Shop.create title: ["test"], (err, resource) =>
          triggered.should.equal true
          done()

      # TODO: Do we want to allow adding after events to instances of a model?
      it.skip "can be added to instances", (done) ->
        triggered = false

        shop = App.Shop.build title: ["test"]

        shop.after "save", (cb) ->
          triggered = true
          cb()

        shop.save ->
          triggered.should.equal true
          done()
