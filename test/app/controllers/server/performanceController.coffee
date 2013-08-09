class App.PerformanceController extends Salad.Controller
  test: ->
    done = =>
      @render json: param: @params.param

    setTimeout done, 200