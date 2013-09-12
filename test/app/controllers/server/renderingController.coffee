class App.RenderingController extends Salad.Controller
  @layout "test"

  test: ->
    @render "rendering/test", layout: false

  arguments: ->
    @render "rendering/arguments", name: "Seb", layout: false

  layoutTest: ->
    @render "rendering/test"

  env: ->
    @render "rendering/env", layout: false

  partial: ->
    @render "rendering/partial", layout: false

  applicationLayout: ->
    @render "rendering/test", layout: "application"

  show: ->
    App.Todo.first (err, todo) =>
      @render "rendering/model", model: todo

  list: ->
    App.Todo.all (err, todos) =>
      @render "rendering/list", models: todos

  array: ->
    data = ["1"]
    @render "rendering/array", models: data

  renderTwice: ->
    @render json: one: true, status: 200
    @render json: two: true, status: 200
