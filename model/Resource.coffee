http      = require 'http'
url       = require 'url'
validator = require 'validator'
check     = require 'check-types'


class Resource

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
    throw new Error 'Invalid status code' unless ''+statusCode in Object.keys http.STATUS_CODES

    @status_code = statusCode

  setHTTPVersion: (version) ->
    @http_version = version        

  setServer: (server) ->
    throw new Error 'Invalid server' unless typeof server is 'string'
    @server = server

  setLastChecked: (date) ->
    throw new Error 'Invalid date' unless date instanceof Date

    @last_checked = date

  setRequestTime: (requestTime) ->
    throw new Error 'Invalid time' unless check.isPositiveNumber(requestTime) or requestTime is 0
    @request_time = requestTime

  setContentType: (contentType) ->
    throw new Error 'Invalid content type' unless typeof contentType is 'string'
    @content_type = contentType

Resource.defaultProtocol = 'http:'
Resource.defaultPort     = 
  'http:': 80
  'https:': 443
Resource.defaultPath     = '/'

module.exports = Resource