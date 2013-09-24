Salad.Router.register (router) ->
  router.match("/photos", "GET").to("photos.index")
  router.match("/locations/asdasd", "GET").to("locations.create")

  router.resource("locations", "locations", "location")

  router.get("/parents(.:format)", "GET").to("parents.index")
  router.get("/parent/:parentId/children(.:format)").to("childs.index")
  router.get("/children(.:format)").to("childs.index")

  router.resource("paginations", "pagination", "location")

  router.get("/rendering/test").to("rendering.test")
  router.get("/rendering/arguments").to("rendering.arguments")
  router.get("/rendering/layoutTest").to("rendering.layoutTest")
  router.get("/rendering/env").to("rendering.env")
  router.get("/rendering/partial").to("rendering.partial")
  router.get("/rendering/applicationLayout").to("rendering.applicationLayout")
  router.get("/rendering/renderTwice").to("rendering.renderTwice")
  router.get("/rendering/show").to("rendering.show")
  router.get("/rendering/list").to("rendering.list")
  router.get("/rendering/array").to("rendering.array")

  router.get("/performance").to("performance.test")


  router.resource("todos", "todos", "todo")
  router.resource("validations", "validations", "validation")

  router.get("/triggers/test").to("trigger.test")
  router.get("/triggers/afterTest").to("trigger.afterTest")
  router.get("/triggers/afterActionTest").to("trigger.afterActionTest")
