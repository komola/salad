class App.WelcomeMailer extends Salad.Mailer
  welcome: (todo, callback) ->
    options =
      subject: "Your todos"
      to: "user@company.tld"
      from: "root@localhost"
      text: => @render "todo/welcome_text", model: todo
      html: => @render "todo/welcome_html", model: todo

    @mail options, callback
