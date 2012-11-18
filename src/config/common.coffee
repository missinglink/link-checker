config =
  development:
    db:
      protocol: "mongodb"
      host:     "127.0.0.1"
      dbName:   "linkchecker"
      port:     27017
      user:     null
      password: null
    server:
      domain: "local.linkchecker.com"
      auth:
        salt: "567890olkjmnhy"
      listenPort: 9999
      session:
        secret: "wdcvbhjuytrfdertyjnbvcfdghjuygfc"
  staging:
    db:
      protocol: "mongodb"
      host:     "alex.mongohq.com"
      dbName:   "nodejitsudb692693884068"
      port:     10035
      user:     "nodejitsu"
      password: "791b9e04e8e79de3f42c0ca77c9ddd47"
    server:
      domain: "stage.linkchecker.com"
      auth:
        salt: "mNhh&*M90u0j"
      listenPort: 9999
      session:
        secret: "wdcvbhjuytsdfsfdsdfsdvcfdghjuygfc"
  production:
    db:
      protocol: "mongodb"
      host:     "127.0.0.1"
      dbName:   "linkchecker"
      port:     27017
      user:     ""
      password: ""
    server:
      domain: "www.linkchecker.com"
      auth:
        salt: "jKI&YHGHKo?98"
      listenPort: 9999
      session:
        secret: "wdcvbhju456365453745{}}dghjuygfc"

exports.config = config