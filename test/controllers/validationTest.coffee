describe "Salad.Controller", ->
  describe "#validate", ->
    describe "#create", ->
      it "should return error message when data is not valid", (done) ->
        agent.post(":3001/validations")
          .send(validation: { field: "New todo"})
          .end (res) ->
            res.status.should.equal 400
            assert.ok res.body.error

            done()

    describe "#update", ->
      it "should return error message when data is not valid", (done) ->
        App.Validation.create field: "valid", (err, validation) ->
          agent.put(":3001/validations/#{validation.get("id")}.json")
            .send(validation: { field: "invalid" })
            .end (res) ->
              res.status.should.equal 400
              assert.ok res.body.error

              done()
