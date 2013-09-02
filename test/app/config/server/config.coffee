config = {}

config.database =
  testing:
    username: "testing"
    password: "testing"
    host: "localhost"
    database: "salad-testing"
    port: 5432

config.mailer =
  testing:
    transport: "debug"
    user: ""
    password: ""
    host: ""
    ssl: true

module.exports = config