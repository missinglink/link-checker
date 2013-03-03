Resource = require 'model/Resource'

class ResourceMapper

  @marshall: (model) ->
    
    throw new Error 'Invalid Resource' unless model instanceof Resource

  @unmarshall: (response, resource, start) ->

    throw new Error 'Invalid Data' unless typeof response is 'object'
    throw new Error 'Invalid Resource' unless resource instanceof Resource

    # console.log 'URI', resource.uri
  
    resource.setHTTPVersion response.httpVersion if response.httpVersion
    resource.setStatusCode response.statusCode if response.statusCode

    # console.log 'STATUS', response.statusCode

    resource.setLastChecked new Date()
    if response.headers
      resource.setServer response.headers.server if response.headers.server
      resource.setContentType response.headers['content-type'] if response.headers['content-type']

    resource.setRequestTime Date.now()-start

    # console.log 'ELAPSED TIME', Date.now()-start

    return resource

module.exports = ResourceMapper