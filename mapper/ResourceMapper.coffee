Resource = require 'model/Resource'
DateMapper = require 'mapper/type/DateMapper'

class ResourceMapper

  @marshall: (model) ->
    
    throw new Error 'Invalid Model' unless model instanceof Resource

    data = {}
    data.statusCode = model.statusCode
    data.hostname = model.hostname
    data.protocol = model.protocol
    data.path = model.path
    data.uri = model.uri
    if model.httpVersion then data.httpVersion = model.httpVersion
    if model.server then data.server = model.server
    data.lastCheckingDate = DateMapper.marshall model.lastCheckingDate

    return data

  @unmarshall: (data) ->

    return null if data is null
    
    throw new Error 'Invalid Data' unless typeof(data) is 'object'

    resource = new Resource data.uri
    resource.setStatusCode data.statusCode
    resource.setLastCheckingDate DateMapper.unmarshall data.lastCheckingDate
    resource.setHTTPVersion data.httpVersion
    if data.server then resource.setServer data.server

    return resource

module.exports = ResourceMapper