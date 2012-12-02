httpClient    = require 'http'
Resource      = require 'model/Resource'
defaultMethod = 'GET'

class Crawler

  constructor: (resourceRepository, resourceCache) ->
    throw new Error 'Invalid param' unless resourceRepository?
    throw new Error 'Invalid param' unless resourceCache?
    @resourceRepository = resourceRepository
    @resourceCache = resourceCache

  cacheStatusCode: (uri, statusCode) ->
    @resourceCache.save uri, statusCode

  storeResource: (resource) ->
    @resourceRepository.save resource, (err) ->
      if err? then throw new Error err

  # crawl an url passed using an HTTP client
  crawlUrl: (resource, sendUrlStatus) ->
    throw new Error 'invalid resource type' unless resource instanceof Resource
    
    clientRequest = httpClient.request resource, (res) =>
      resource.setStatusCode res.statusCode
      resource.setLastCheckingDate new Date()
      sendUrlStatus resource.statusCode
      @cacheStatusCode resource.uri, resource.statusCode
      @storeResource resource

    clientRequest.on 'error', (e) =>
      resource.setStatusCode 500
      sendUrlStatus resource.statusCode
      @cacheStatusCode resource.uri, resource.statusCode
      @storeResource resource

    clientRequest.end()

  lookup: (requestedUrl, sendUrlStatus) ->

    # fetching from the cache
    @resourceCache.lookup requestedUrl, (err, statusCode) =>
      if err? then throw new Error err

      if statusCode?
        # send back the cached URL status
        sendUrlStatus statusCode
      else
        # fetch from repository
        resource = new Resource requestedUrl
        @resourceRepository.findOne {uri:resource.uri}, (err, res) =>
          if err? then throw new Error err

          if res?
            @cacheStatusCode res.uri, res.statusCode
            sendUrlStatus res.statusCode
          else
            # crawl the new URL
            @crawlUrl resource, sendUrlStatus

module.exports = Crawler