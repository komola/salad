Salad.Router.register (router) ->
  router.match("/photos", "GET").to("photos.index")
  router.match("/locations/asdasd", "GET").to("locations.create")
  router.resource("locations")