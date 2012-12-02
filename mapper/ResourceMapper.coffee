Resource = require 'model/Resource'

class ResourceMapper

  @marshall: (model) ->
    
    return null if data is null

    throw new Error 'Invalid Model' unless model instanceof Resource

    data = {}
    data.statusCode = model.statusCode
    data.hostname = model.hostname
    data.protocol = model.protocol
    data.path = model.path
    data.uri = model.uri
    data.lastCheckingDate = model.lastCheckingDate

    return data

  @unmarshall: (data) ->

    return null if data is null
    
    throw new Error 'Invalid Data' unless typeof(data) is 'object'

    resource = new Resource data.uri
    resource.setStatusCode data.statusCode
    resource.setLastCheckingDate data.lastCheckingDate

    return resource

module.exports = ResourceMapper