Resource = require 'model/Resource'

class ResourceMapper

  @marshall: (model) ->
    
    throw new Error 'Invalid Model' unless model instanceof Resource

    data = {}
    data.status_code = model.status_code
    data.hostname = model.hostname
    data.protocol = model.protocol
    data.path = model.path
    data.uri = model.uri
    if model.http_version then data.http_version = model.http_version
    if model.server then data.server = model.server
    data.last_checked = model.last_checked
    data.request_time = model.request_time if model.request_time
    data.content_type = model.content_type if model.content_type

    return data

  @unmarshall: (data) ->

    return null if data is null
    
    throw new Error 'Invalid Data' unless typeof data is 'object'

    resource = new Resource data.uri
    resource.setStatusCode data.status_code
    resource.setLastChecked data.last_checked
    resource.setHTTPVersion data.http_version
    if data.server then resource.setServer data.server
    resource.setRequestTime data.request_time if data.request_time
    resource.setContentType data.content_type if data.content_type

    return resource

module.exports = ResourceMapper