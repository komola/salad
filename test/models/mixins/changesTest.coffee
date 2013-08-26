describe "App.Model changes", ->
  it "does not take snapshot on building", ->
    todo = App.Todo.build title: "test"

    assert.ok todo.getSnapshot()

    _.keys(todo.getChangedAttributes()).length.should.equal 1

  it "takes snapshot after saving", (done) ->
    todo = App.Todo.build title: "test"

    todo.save ->
      todo.getSnapshot().title.should.equal "test"

      done()

  it "takes snapshot after creating", (done) ->
    App.Todo.create title: "test", (err, resource) ->
      assert.ok resource.getSnapshot()
      resource.getSnapshot().title.should.equal "test"

      _.keys(resource.getChangedAttributes()).length.should.equal 0

      done()

  it "calculates changes correctly", ->
    todo = App.Todo.build title: "test"

    todo.set "title", "foo"

    todo.getChangedAttributes().should.be.instanceof Object

    assert.ok todo.getChangedAttributes().title

    todo.getChangedAttributes().title.should.be.instanceof Array
    assert.isTrue todo.getChangedAttributes().title[0] is undefined
    todo.getChangedAttributes().title[1].should.equal "foo"

  it "has no changes after save", (done) ->
    todo = App.Todo.build title: "test"

    todo.save (err, res) ->
      _.keys(todo.getChangedAttributes()).length.should.equal 0

      done()