class App.ErrorController extends Salad.Controller
  404: ->
    @response.send "404!"
