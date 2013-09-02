class Salad.Mailer extends Salad.Base
  @mixin require "./mailers/mixins/renderers"

  mail: (options, callback) ->
    defaultOptions =
      subject: ""
      to: ""
      from: ""
      options: null

    options = _.extend defaultOptions, options

    unless options.to
      throw new Error "No recipient given!"

    if options.html
      options.html = options.html()

    if options.text
      options.text = options.text()

    emailConnection = Salad.Config.mailer[Salad.env]
    transport = @getTransport emailConnection.transport

    mailOptions =
      credentials: emailConnection
      message: options

    transport.mail mailOptions, callback

  getTransport: (name) ->
    name = _.classify name
    transport = Salad.Mailer[name]

    unless transport
      throw new Error "Could not find email transport #{name}"

    transport

require "./mailers/smtp"
require "./mailers/debug"