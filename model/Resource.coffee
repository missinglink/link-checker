http          = require 'http'
url           = require 'url'
validator     = require 'validator'
classChecker  = require 'lib/utils/classChecker'
absolutizeURI = require 'lib/utils/absolutizeURI'

class Resource

  constructor: (uri) ->
    throw new Error 'Invalid uri' unless typeof uri is 'string'
    validator.check(uri, 'Invalid uri').isUrl()

    uri = addDefaultProtocol uri

    urlParts = url.parse uri, true
    throw new Error 'invalid hosrtname' unless urlParts.hostname
    
    @hostname = urlParts.hostname
    @protocol = urlParts.protocol || Resource.defaultProtocol
    @port = urlParts.port || Resource.defaultPort
    @path = urlParts.path || Resource.defaultPath

    @uri = uri

  setStatusCode: (statusCode) ->
    throw new Error 'Invalid status code' unless ''+statusCode in Object.keys http.STATUS_CODES

    @statusCode = statusCode

  setHTTPVersion: (version) ->
    @httpVersion = version        

  setServer: (server) ->
    @server = server    

  setLastCheckingDate: (date) ->
    throw new Error 'Invalid date' unless classChecker(date) is 'date'

    @lastCheckingDate = date

Resource.defaultProtocol = 'http:'
Resource.defaultPort     = 80
Resource.defaultPath     = '/'

Resource.allow = (requestedUrl) ->
  if requestedUrl.match /^(http:|https:|ftp:)?\/\/.*$/ then return true
  return false

Resource.removeFragment = (uri) ->
  urlParts = uri.split('#')
  return urlParts[0]

Resource.addTrailingSlash = (uri) ->
  uri = uri + '/' unless uri.charAt(uri.length) is '/'
  return uri

Resource.getAbsoluteURI = (requestedUrl, originalDomain) ->
  return absolutizeURI originalDomain, requestedUrl

module.exports = Resource

addDefaultProtocol = (uri) ->
  regex = new RegExp "^[a-z]+:\/\/"
  return Resource.defaultProtocol + '//' + uri unless regex.test uri
  return uri