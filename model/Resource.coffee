http         = require 'http'
url          = require 'url'
validator    = require 'validator'
classChecker = require '../lib/utils/classChecker'

class Resource

  constructor: (uri) ->
    throw new Error 'Invalid uri' unless typeof uri is 'string'
    validator.check(uri, 'Invalid uri').isUrl()

    uri = addDefaultProtocol uri

    urlParts = url.parse uri, true
    if urlParts.hostname? then @hostname = urlParts.hostname

    @protocol = urlParts.protocol || Resource.defaultProtocol
    if urlParts.port? then @port = urlParts.port

    @uri = uri

  setStatusCode: (statusCode) ->
    throw new Error 'Invalid status code' unless statusCode in Object.keys http.STATUS_CODES

    @statusCode = statusCode

  setLastCheckingDate: (date) ->
    throw new Error 'Invalid date' unless classChecker(date) is 'date'

    @lastCheckingDate = date

Resource.defaultProtocol = 'http:'

module.exports = Resource

addDefaultProtocol = (uri) ->
  regex = new RegExp "^[a-z]+:\/\/"
  return Resource.defaultProtocol + '//' + uri unless regex.test uri
  return uri