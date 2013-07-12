Salad.Router.register (router) ->
  router.match("/photos", "GET").to("photos.index")
  router.match("/locations/asdasd", "GET").to("locations.create")

  router.resource("locations", "locations", "location")

  router.get("/parent/:parentId/children(.:format)").to("childs.index")
  router.get("/children(.:format)").to("childs.index")

  router.resource("paginations", "pagination", "location")