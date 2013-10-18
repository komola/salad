mailer = null

describe "Salad.Mailer", ->
  before ->
    mailer = new App.WelcomeMailer

  describe "#render", ->
    it "should render templates", ->

      content = mailer.render "rendering/test"

      content.should.equal "<h1>Hello World!</h1>"

  describe "#mail", ->
    todo = null

    beforeEach (done) ->
      App.Todo.create title: "Todo", (err, res) ->
        todo = res
        done()

    it "should send an email to the address", (done) ->
      mailer.welcome todo, (err, message) ->
        message.subject.should.equal "Your todos"
        message.to.should.equal "user@company.tld"
        message.from.should.equal "root@localhost"
        message.text.should.equal "text1"
        message.attachment[0].data.should.equal "html1"

        done()
