class App.RenderingController extends Salad.Controller
  test: ->
    @render "rendering/test"

  arguments: ->
    @render "rendering/arguments", name: "Seb"