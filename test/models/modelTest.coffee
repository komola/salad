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

      # TODO See https://github.com/sequelize/sequelize/issues/815
      it.skip "does not break when id is set to null", (done) ->
        attribs =
          title: "Test"
        App.Todo.create attribs, (err, resource) =>
          assert.ok resource.get("id")

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

    describe "#destroy", ->
      it "destroys the model", (done) ->
        App.Location.create title: "Test", (err, res) ->
          res.destroy =>
            App.Location.count (err, count) =>
              count.should.equal 0

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


    describe "#build", ->
      it "creates an instance with association information", (done) ->
        App.Location.create title: "Parent", (err, resource) =>
          child = resource.getChildren().build title: "Child"

          child.get("parentId").should.equal 1

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
                assert.equal newChildObject.get("parentId"), undefined

                done()


    describe "#includes", ->
      it "eager-loads one associated objects", (done) ->
        App.Operator.create title: "Operator", (err, operator) =>
          operator.getLocations().create title: "Location", (err, location) =>
            App.Location.include([App.Operator]).all (err, locations) =>

              locations.length.should.equal 1
              _.keys(locations[0].getAssociations()).length.should.equal 1
              locations[0].getAssociations().operator.get("id").should.equal operator.get("id")

              assert.isDefined locations[0].toJSON().operator
              locations[0].toJSON().operator.id.should.equal operator.get("id")

              done()

      it "eager-loads many associated objects", (done) ->
        App.Operator.create title: "Operator", (err, operator) =>
          operator.getLocations().create title: "Location", (err, location) =>
            App.Operator.include([App.Location]).all (err, operators) =>

              operators.length.should.equal 1
              _.keys(operators[0].getAssociations()).length.should.equal 1
              operators[0].getAssociations().locations[0].get("id").should.equal location.get("id")

              data = operators[0].toJSON()

              assert.isTrue data.locations instanceof Array

              data.locations.length.should.equal 1


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
