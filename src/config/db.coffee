MongoGateway = require 'lib/MongoGateway'

module.exports.init = (app) ->

  db = app.config.db
  dsn = db.protocol + '://'
  if db.user? then dsn += db.user
  if db.password? then dsn += ':' + db.password
  dsn += db.host + ':' + db.port + '/' + db.dbName
  
  console.log 'Connecting to database: ' + dsn  

  MongoGateway.setLogger app.mongoLogger
  MongoGateway.init db
  MongoGateway.connect db.user, db.password