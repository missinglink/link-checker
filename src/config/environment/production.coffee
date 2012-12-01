module.exports = (app) ->

  console.log 'Loading config: PRODUCTION'
  
  app.config = require('src/config/common').config.production