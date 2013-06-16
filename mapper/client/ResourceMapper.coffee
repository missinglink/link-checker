Resource = require 'model/Resource'


unmarshall = (response, resource, start) ->

  throw new Error 'Invalid Data' unless typeof response is 'object'
  throw new Error 'Invalid Resource' unless resource instanceof Resource
  throw new Error 'Invalid start' unless start instanceof Date

  # console.log 'URI', resource.uri

  resource.setHTTPVersion response.httpVersion if response.httpVersion?
  resource.setStatusCode response.statusCode if response.statusCode?

  # console.log 'STATUS', response.statusCode

  resource.setLastChecked new Date()
  resource.setServer response.headers.server if response.headers?.server?
  resource.setContentType response.headers['content-type'] if response.headers?['content-type']?

  resource.setRequestTime Date.now()-start.getTime()

  # console.log 'ELAPSED TIME', Date.now()-start.getTime()

  return resource


module.exports = {unmarshall}