env = process.env.NODE_ENV || "production"

port = switch env
  when "production" then 80
  when "test" then 3001
  else 3000

if env isnt "test"
  Salad.Bootstrap.run
    port: port
    env: env
