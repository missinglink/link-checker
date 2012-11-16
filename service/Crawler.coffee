httpClient    = require 'http'
Resource      = require '../model/Resource'
defaultMethod = 'GET'

class Crawler

  # crawl an url passed using an HTTP client
  crawlUrl: (resource, storeUrl, sendUrlStatus) ->
    throw new Error 'invalid resource type' unless resource instanceof Resource
    
    clientRequest = httpClient.request resource, (res) ->
      resource.setStatusCode res.statusCode
      resource.setLastCheckingDate new Date()
      sendUrlStatus resource
      storeUrl resource

    clientRequest.on 'error', (e) =>
      resource.setStatusCode 500
      sendUrlStatus resource
      storeUrl resource

    clientRequest.end()

module.exports = Crawler