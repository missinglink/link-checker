module.exports = (app) ->

  console.log 'Loading config: DEVELOPMENT'
  
  app.config = require('src/config/common').config.development
  
  app.mongoLogger =
    error: (message, object) ->
      console.log 'MongoDriver.Logger.error'
      console.log message
      console.log object
    log: (message, object) ->
      console.log 'MongoDriver.Logger.log'
      console.log message
      console.log object
    debug: (message, object) ->
      console.log '\x1B[0;36mMongoDB:\x1B[0m %s', message
      console.log object.json.collectionName if object?.json?.collectionName?
      console.log object.json.query if object?.json?.query?
    doDebug: true