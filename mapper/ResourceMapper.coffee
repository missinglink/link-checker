Resource = require 'model/Resource'

check = require 'check-types'


marshall = (model) ->
  
  throw new Error 'Invalid Resource' unless model instanceof Resource

  data = {}
  data.status_code = model.status_code
  data.hostname = model.hostname
  data.protocol = model.protocol
  data.path = model.path
  data.uri = model.uri
  data.http_version = model.http_version if model.http_version?
  data.server = model.server if model.server?
  data.last_checked = model.last_checked
  data.request_time = model.request_time if model.request_time?
  data.content_type = model.content_type if model.content_type?

  return data


unmarshall = (data) ->

  return null if data is null
  
  throw new Error 'Invalid data' unless check.isObject data

  resource = new Resource data.uri
  resource.setStatusCode data.status_code
  resource.setLastChecked data.last_checked
  resource.setHTTPVersion data.http_version
  resource.setServer data.server if data.server?
  resource.setRequestTime data.request_time if data.request_time?
  resource.setContentType data.content_type if data.content_type?

  return resource


module.exports = {marshall, unmarshall}
