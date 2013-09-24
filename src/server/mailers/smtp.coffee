email = require "emailjs/email"

class Salad.Mailer.Smtp
  @mail: (options, callback) ->
    defaultOptions =
      credentials:
        user: ""
        password: ""
        host: ""
        ssl: true
      message:
        to: ""
        from: ""
        cc: undefined
        subject: undefined
        text: undefined
        html: undefined
        attachments: []
        options: undefined

    options = _.extend defaultOptions, options

    connection = email.server.connect options.credentials

    if options.message.options?.headers
      options.message = _.extend options.message, options.message.options.headers

      delete options.message.options.headers

    delete options.message.options

    connection.send options.message, callback