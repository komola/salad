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
        attachment: []
        options: undefined

    options = _.extend defaultOptions, options
    
    # Check if html is specified and attach it to the email as an alternative.
    if options.message.html != undefined
      if !options.message.attachment
        options.message.attachment = []

      options.message.attachment.push({data:options.message.html, alternative:true})
    delete options.message.html

    connection = email.server.connect options.credentials

    if options.message.options?.headers
      options.message = _.extend options.message, options.message.options.headers

      delete options.message.options.headers

    delete options.message.options

    connection.send options.message, callback
