module.exports = (app) ->

  console.log 'Loading config: STAGING'
  
  app.config = require('src/config/common').config.staging