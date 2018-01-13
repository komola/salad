describe "App.Controller Triggers", ->
  describe "#before", ->
    it "is executed before actions", (done) ->
      agent.get(":3001/triggers/test").end (err, res) ->
        assert.isTrue res.body.beforeTest

        done()

      return null

  describe "#beforeAction", ->
    it "is executed before every action", (done) ->
      agent.get(":3001/triggers/test").end (err, res) ->
        assert.isTrue res.body.beforeActionTest

        done()

      return null

  describe "#after", ->
    it "is executed after actions", (done) ->
      @timeout 4000

      agent.get(":3001/triggers/afterTest").end (err, res) ->
        query = =>
          App.Todo.first (err, res) ->
            res.get("title").should.equal "afterTest"

            done()

        setTimeout query, 400

      return null

  describe "#afterAction", ->
    it "is executed after every action", (done) ->
      @timeout 4000

      agent.get(":3001/triggers/afterActionTest").end (err, res) ->

        query = =>
          App.Todo.first (err, res) ->
            res.get("title").should.equal "afterActionTest"
            done()

        setTimeout query, 400

      return null
