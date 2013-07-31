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
