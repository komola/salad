describe "Salad.Validator", ->
  describe "#check", ->
    it "should apply checks", ->
      result = Salad.Validator.check email: "asd",
        email:
          isEmail: true

      result.should.eql
        email: ["Invalid email"]

      return null

    it "should accept custom error messages", ->
      result = Salad.Validator.check email: "asd",
        email:
          isEmail: "A"

      result.should.eql
        email: ["A"]
      return null

    it "should check for required fields", ->
      result = Salad.Validator.check email: "asd",
        firstname:
          notNull: true

      result.should.eql
        firstname: ["String is empty"]

      return null

    it "should not check non-existent non-required fields", ->
      result = Salad.Validator.check email: "asd",
        firstname:
          isAlphanumeric: true

      result.should.eql true
      return null

    it "should be able to check isIn", ->
      result = Salad.Validator.check foo: "asd",
        foo:
          isIn: ["A", "B"]

      result.should.eql
        foo: ["Unexpected value or invalid argument"]

      result = Salad.Validator.check foo: "A",
        foo:
          isIn: ["A", "B"]

      result.should.eql true
      return null

    it "should be possible to add options and custom message", ->
      result = Salad.Validator.check foo: "asd",
        foo:
          isIn:
            options: ["A", "B"]
            message: "C"

      result.should.eql
        foo: ["C"]
      return null

    it "should be possible to just specify options", ->
      result = Salad.Validator.check foo: "asd",
        foo:
          isIn:
            options: ["A", "B"]

      result.should.eql
        foo: ["Unexpected value or invalid argument"]
      return null
