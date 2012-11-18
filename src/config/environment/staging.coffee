module.exports = (app) ->

  console.log 'Loading config: STAGING'
  
  app.config = require('../common').config.staging