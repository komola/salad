async = require "async"

describe "Controller", ->
  describe "#pagination()", ->
    beforeEach (done) ->
      iterator = (i, cb) ->
        App.Location.create title: "title"+i, (err, res) =>
          cb()

      async.timesSeries 20, iterator, done

    it "transforms the JSON index response", (done) ->
      agent.get(":3001/paginations.json")
        .end (res) ->
          res.ok.should.equal true

          should.exist(res.body.total)
          should.exist(res.body.page)
          should.exist(res.body.totalPages)
          should.exist(res.body.offset)
          should.exist(res.body.limit)
          should.exist(res.body.items)

          return done()

          done()

    it "does not affect get requests", (done) ->
      App.Location.create title: "test", (err, resource) ->
        agent.get(":3001/paginations/#{resource.get("id")}.json")
          .end (res) ->
            res.ok.should.equal true

            should.exist(res.body.id)

            done()

    it "calculates total correct", (done) ->
      agent.get(":3001/paginations.json")
        .end (res) ->
          res.ok.should.equal true

          res.body.total.should.equal 20

          done()

    it "accepts limit as parameter", (done) ->
      agent.get(":3001/paginations.json?limit=3")
        .end (res) ->
          res.ok.should.equal true

          res.body.items.length.should.equal 3

          done()

    it "accepts offset as parameter", (done) ->
      agent.get(":3001/paginations.json?offset=3")
        .end (res) ->
          res.ok.should.equal true

          res.body.items[0].id.should.equal 4

          done()

    it "does not transform the result if there is an error", (done) ->
      agent.get(":3001/paginations.json?error=true")
        .end (res) ->
          res.statusCode.should.equal 401

          assert.ok res.body.error

          done()
