MongoGateway = require 'lib/MongoGateway'

config = require 'src/config/common'


module.exports.init = (app) ->

  userAndPassDSN = (
    if config.db.user? and config.db.password? then "#{config.db.user}:#{config.db.password}@"
    else ''
  )

  console.log "Connected to DB: #{config.db.protocol}://#{userAndPassDSN}#{config.db.host}:#{config.db.port}/#{config.db.dbName}"

  MongoGateway.setLogger app.mongoLogger
  MongoGateway.init config.db
  MongoGateway.connect config.db.user, config.db.password
