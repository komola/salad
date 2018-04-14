config = {}

config.database =
  test:
    username: "testing"
    password: "testing"
    host: "postgres"
    database: "salad-testing"
    port: 5432
    logging: false
    pool:
      maxConnections: 5
      maxIdleTime: 30

config.mailer =
  test:
    transport: "debug"
    user: ""
    password: ""
    host: ""
    ssl: true

module.exports = config
