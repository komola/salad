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
        expect(res.attributes).to.exist

        res.attributes.id.should.equal 1
        res.attributes.title.should.equal params.title
        res.attributes.description.should.equal params.description

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
        expect(res.attributes).to.exist

        res.attributes.id.should.equal 1
        res.attributes.title.should.equal "Foo"
        res.attributes.description.should.equal params.description

        done()

    describe "#save", ->
      it "creates a record when it is new", (done) ->
        resource = App.Location.build title: "Test"

        resource.attributes.title.should.equal "Test"

        assert.isTrue resource.isNew

        resource.save (err, res) =>
          assert.ok res
          assert.ok res.attributes.id
          res.isNew.should.equal false

          res.attributes.title.should.equal resource.attributes.title

          done()

      it "updates a record when it is not new", (done) ->
        App.Location.create title: "Test", (err, res) =>

          res.attributes.title = "Foo"
          res.save (err, res) =>
            assert.ok res
            assert.ok res.attributes.id
            res.isNew.should.equal false

            res.attributes.title.should.equal "Foo"

            done()

  describe "attributes", ->
    describe "#set", ->
      it "sets an attribute to a specific value", ->
        location = App.Location.build title: "Test"
        location.set "title", "Foo"

        location.attributes.title.should.equal "Foo"

    describe "#get", ->
      it "returns an attribute", ->
        location = App.Location.build title: "Test"
        location.get("title").should.equal "Test"