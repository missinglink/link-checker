MongoGateway = require 'lib/MongoGateway'

module.exports.init = (app) ->

  console.log 'Connecting to database: ' + app.dsn

  MongoGateway.setLogger app.mongoLogger
  MongoGateway.init app.config.db
  MongoGateway.connect app.config.db.user, app.config.db.password