http          = require 'http'
url           = require 'url'
validator     = require 'validator'
classChecker  = require 'lib/utils/classChecker'
absolutizeURI = require 'lib/utils/absolutizeURI'

class Resource

  constructor: (uri, filters = []) ->
    throw new Error 'Invalid uri' unless typeof uri is 'string'
    validator.check(uri, 'Invalid uri').isUrl()
    throw new Error 'Invalid filters' unless Array.isArray filters

    for filter in filters
      throw new Error 'filter is not a function' unless filter instanceof Function
      uri = filter uri

    @urlParts = url.parse uri, true
    throw new Error 'invalid hostname' unless @urlParts.hostname
    
    @hostname = @urlParts.hostname
    @protocol = @urlParts.protocol || Resource.defaultProtocol
    @port = @urlParts.port || Resource.defaultPort
    @path = @urlParts.path || Resource.defaultPath

    @filters = filters
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
    throw new Error 'Invalid date' unless classChecker(date) is 'date'

    @last_checked = date

  setRequestTime: (requestTime) ->
    throw new Error 'Invalid time' unless typeof requestTime is 'number'
    @request_time = requestTime

  setContentType: (contentType) ->
    throw new Error 'Invalid content type' unless typeof contentType is 'string'
    @content_type = contentType

Resource.defaultProtocol = 'http:'
Resource.defaultPort     = 80
Resource.defaultPath     = '/'

Resource.isAbsolute = (uri) ->
  return false unless typeof uri is 'string'
  p = url.parse uri, true
  return false unless p.protocol
  return false unless p.hostname
  return false unless p.pathname
  return false unless p.pathname.length > 1
  return true

Resource.allow = (requestedUrl) ->
  if requestedUrl.match /^(http:|https:|ftp:)?\/\/.*$/ then return true
  return false

Resource.removeFragment = (uri) ->
  urlParts = uri.split('#')
  return urlParts[0]

Resource.getAbsoluteURI = (requestedUrl, originalDomain) ->
  return absolutizeURI originalDomain, requestedUrl

module.exports = Resource

Resource.addDefaultProtocol = (uri) ->
  defProtocol = Resource.defaultProtocol
  defProtocol = Resource.defaultProtocol + '//' unless uri.match /^\/\/.*$/
  return defProtocol + uri unless uri.match /^[a-z]+:/
  return uri

# Converting the scheme and host to lower case. 
# The scheme and host components of the URL are case-insensitive. Most normalizers will convert them to lowercase. 
# Example:
# HTTP://www.Example.com/ → http://www.example.com/
Resource.lowerCase = (uri) ->
  urlParts = url.parse uri
  urlParts.protocol = urlParts.protocol.toLowerCase()
  urlParts.hostname = urlParts.hostname.toLowerCase()
  
  return url.format urlParts

# Removing the default port. 
# The default port (port 80 for the “http” scheme) may be removed from (or added to) a URL.
# Example:
# http://www.example.com:80/bar.html → http://www.example.com/bar.html
Resource.removePort = (uri) ->
  urlParts = url.parse uri
  urlParts.host = urlParts.host.replace /^(.*):[0-9]+(.*)$/, '$1$2'
  delete urlParts.port
  return url.format urlParts

Resource.useCanonicalSlashes = (uri) ->
  up = url.parse uri
  if up.pathname isnt '/' and up.pathname.charAt(up.pathname.length-1) is '/'
    up.pathname = up.pathname.substring 0, up.pathname.length-1
  if up.path isnt '/' and up.path.charAt(up.path.length-1) is '/'
    up.path = up.path.substring 0, up.path.length-1

  return url.format up

# Capitalizing letters in escape sequences. 
# All letters within a percent-encoding triplet (e.g., "%3A") are case-insensitive, and should be capitalized.
# Example:
# http://www.example.com/a%c2%b1b → http://www.example.com/a%C2%B1b
# 
# Decoding percent-encoded octets of unreserved characters.
# For consistency, percent-encoded octets in the ranges of ALPHA (%41–%5A and %61–%7A), DIGIT (%30–%39), hyphen (%2D), period (%2E), 
# underscore (%5F), or tilde (%7E) should not be created by URI producers and, when found in a URI, should be decoded to their 
# corresponding unreserved characters by URI normalizers.[2] 
# Example:
# http://www.example.com/%7Eusername/ → http://www.example.com/~username/