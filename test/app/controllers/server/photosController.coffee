class App.PhotosController extends Salad.RestfulController
  @resource "photos"

  index: ->
    @response.send "Hallo!"
