http      = require 'http'
url       = require 'url'
validator = require 'validator'
check     = require 'check-types'


class Resource

  @defaultProtocol = 'http:'
  
  @defaultPort = 'http:': 80, 'https:': 443
  
  @defaultPath = '/'
  
  @isAbsolute = (uri) ->
    return false unless typeof uri is 'string'
    p = url.parse uri, true
    return false unless p.protocol
    return true if p.protocol is 'mailto:'
    return false unless p.hostname
    return false unless p.pathname
    return false unless p.pathname.length > 0
    return true


  @isProtocolAllowed = (uri) ->
    return true unless Resource.isAbsolute uri
    if /^(http:|https:)?\/\/.*$/.test uri then return true
    return false


  constructor: (uri) ->
    throw new Error 'Invalid uri' unless typeof uri is 'string'
    validator.check(uri, 'Invalid uri').isUrl()

    @urlParts = url.parse uri, true
    throw new Error 'invalid hostname' unless @urlParts.hostname
    
    @hostname = @urlParts.hostname
    @protocol = @urlParts.protocol || Resource.defaultProtocol
    @port = @urlParts.port || Resource.defaultPort[@protocol]
    @path = @urlParts.path || Resource.defaultPath

    @uri = uri


  setStatusCode: (statusCode) ->
    throw new Error 'Invalid status code' unless statusCode? and ''+statusCode in Object.keys http.STATUS_CODES
    @status_code = statusCode


  setHTTPVersion: (version) ->
    throw new Error 'Invalid version' unless typeof version is 'string'
    @http_version = version        


  setServer: (server) ->
    throw new Error 'Invalid server' unless typeof server is 'string'
    @server = server


  setLastChecked: (lastChecked) ->
    throw new Error 'Invalid last checked' unless lastChecked? and lastChecked instanceof Date

    @last_checked = lastChecked


  setRequestTime: (requestTime) ->
    throw new Error 'Invalid time' unless check.isPositiveNumber(requestTime) or requestTime is 0
    @request_time = requestTime


  setContentType: (contentType) ->
    throw new Error 'Invalid content type' unless typeof contentType is 'string'
    @content_type = contentType


module.exports = Resource
