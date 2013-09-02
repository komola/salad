class Salad.Mailer.Debug
  @mail: (options, callback) ->
    email = options.message

    callback null, email
