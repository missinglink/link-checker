module.exports =

  db:
    protocol: process.env.DB_PROTOCOL or "mongodb"
    host:     process.env.DB_HOSTNAME or "127.0.0.1"
    dbName:   process.env.DB_DB_NAME or "linkchecker"
    port:     process.env.BD_PORT or 27017
    user:     process.env.DB_USER or null
    password: process.env.DB_PASSWORD or null
  server:
    domain: process.env.SERVER_DOMAIN or "local.linkchecker.com"
    listenPort: process.env.SERVER_PORT or 9999
    session:
      secret: process.env.SERVER_SESSION_SECRET or "wdcvbhjuytrfdertyjnbvcfdghjuygfc"
  redis:
    host: process.env.REDIS_HOSTNAME or '127.0.0.1'
    port: process.env.REDIS_PORT or 6379
    password: process.env.REDIS_PASSWORD or null
  websocket:
    port: process.env.WEBSOCKET_PORT or 3000
