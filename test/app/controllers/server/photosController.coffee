class App.PhotosController extends Salad.RestfulController
  resourceName: "photo"

  index: ->
    @response.send "Hallo!"
