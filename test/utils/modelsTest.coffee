describe "Salad.Utils.Models", ->
  describe "#registered", ->
    it "should return array of all model classes", ->
      models = Salad.Utils.Models.registered()

      assert.ok models
      assert.isTrue models.length > 0

      # only returns models
      for model in models
        assert.isTrue model.prototype instanceof Salad.Model

  describe "#existingDatabaseTables", ->
    it "should return an array of all SQL tables", ->
      tables = Salad.Utils.Models.existingDatabaseTables()

      assert.ok tables
      assert.isTrue tables.length > 0

  describe.skip "#loadFixtures", ->
    it "should require all fixture files", ->
      Salad.Utils.Models.loadFixtures()
