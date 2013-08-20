class App.TriggerController extends Salad.Controller
  @before "test", (done) ->
    @param or= {}
    @param.beforeTest = true

    done()

  @after "afterTest", (done) ->
    App.Todo.create title: "afterTest", (err, res) ->
      done()

  @beforeAction (done) ->
    @param or= {}
    @param.beforeActionTest = true
    done()

  @afterAction (done) ->
    return done() if @params.action isnt "afterActionTest"
    App.Todo.create title: "afterActionTest", (err, res) ->

      done()

  test: ->
    @param or= {}

    data = @param

    @render json: data

  afterTest: ->
    @render json: {}

  afterActionTest: ->
    @render json: {}