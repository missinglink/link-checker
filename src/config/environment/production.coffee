module.exports = (app) ->

  console.log 'Loading config: PRODUCTION'
  
  app.config = require('../common').config.production