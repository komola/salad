describe "Renderer", ->
  it "should have loaded all the templates", ->
    assert.ok Salad.Bootstrap.metadata().templates
    assert.ok Salad.Bootstrap.metadata().templates["rendering/test.hbs"]