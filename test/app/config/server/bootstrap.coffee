env = process.env.NODE_ENV || "production"

port = switch env
  when "production" then 80
  when "testing" then 3001
  else 3000

if env isnt "testing"
  Salad.Bootstrap.run
    port: port
    env: env