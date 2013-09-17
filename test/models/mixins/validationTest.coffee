describe "App.Model #validation", ->
  describe "#validate", ->
    describe "#create", ->
      it "should return errors", (done) ->
        App.Validation.create field: "foo", (err, model) ->
          assert.ok err
          assert.isFalse err.isValid
          err.should.have.property "errors"

          done()

    describe "#update", ->
      it "should return errors", (done) ->
        App.Validation.create field: "valid", (err, model) ->
          assert.ok model

          model.set "field", "invalid value"
          model.save (err, model) ->
            assert.ok err
            assert.isFalse err.isValid
            err.should.have.property "errors"

            done()

    describe "#updateAttributes", ->
      it "should return errors", (done) ->
        App.Validation.create field: "valid", (err, model) ->
          assert.ok model

          model.set "field", "invalid value"
          model.updateAttributes field: "invalid value", (err) ->
            assert.ok err
            assert.isFalse err.isValid
            err.should.have.property "errors"

            done()
