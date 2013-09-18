describe "App.Validator", ->
  describe "#check", ->
    it "should apply checks", ->
      result = App.Validator.check email: "asd",
        email:
          isEmail: true

      result.should.eql
        email: ["Invalid email"]

    it "should accept custom error messages", ->
      result = App.Validator.check email: "asd",
        email:
          isEmail: "A"

      result.should.eql
        email: ["A"]

    it "should check for required fields", ->
      result = App.Validator.check email: "asd",
        firstname:
          notNull: true

      result.should.eql
        firstname: ["String is empty"]

    it "should not check non-existent non-required fields", ->
      result = App.Validator.check email: "asd",
        firstname:
          isAlphanumeric: true

      result.should.eql true

    it "should be able to check isIn", ->
      result = App.Validator.check foo: "asd",
        foo:
          isIn: ["A", "B"]

      result.should.eql
        foo: ["Unexpected value or invalid argument"]

      result = App.Validator.check foo: "A",
        foo:
          isIn: ["A", "B"]

      result.should.eql true

    it "should be possible to add options and custom message", ->
      result = App.Validator.check foo: "asd",
        foo:
          isIn:
            options: ["A", "B"]
            message: "C"

      result.should.eql
        foo: ["C"]

    it "should be possible to just specify options", ->
      result = App.Validator.check foo: "asd",
        foo:
          isIn:
            options: ["A", "B"]

      result.should.eql
        foo: ["Unexpected value or invalid argument"]
