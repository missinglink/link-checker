http = require 'http'

Resource = require 'model/Resource'

ResourceRepository = require 'repository/Resource'

Cache = require 'service/cache/Redis'

mapResponseToResorce = (response, resource, start) ->
  # console.log 'URI', resource.uri
  
  resource.setHTTPVersion response.httpVersion if response.httpVersion
  resource.setStatusCode response.statusCode if response.statusCode

  # console.log 'STATUS', response.statusCode

  resource.setLastChecked new Date()
  if response.headers
    resource.setServer response.headers.server if response.headers.server
    resource.setContentType response.headers['content-type'] if response.headers['content-type']

  resource.setRequestTime Date.now()-start

  # console.log 'ELAPSED TIME', Date.now()-start


class Crawler

  constructor: (resourceCache = Cache, resourceRepository = ResourceRepository) ->
    throw new Error 'Invalid param' unless resourceCache?
    throw new Error 'Invalid param' unless resourceRepository?
    resourceCache.init()
    @resourceRepository = new resourceRepository
    @resourceCache = resourceCache

  cacheStatusCode: (uri, statusCode) ->
    @resourceCache.save uri, statusCode

  storeResource: (resource) ->
    @resourceRepository.save resource, (err) ->
      if err? then throw new Error err

  # crawl an url passed using an HTTP client
  crawlUrl: (resource, sendUrlStatus) ->
    throw new Error 'invalid resource type' unless resource instanceof Resource
    
    # resource.method = 'HEAD'
    resource.method = 'GET'

    options =
      hostname: resource.hostname
      port: resource.port
      method: resource.method
      path: resource.path
      headers: {}

    start = Date.now()
    clientRequest = http.request options, (res) =>
      mapResponseToResorce res, resource, start
      sendUrlStatus resource.status_code
      @cacheStatusCode resource.uri, resource.status_code
      @storeResource resource

    clientRequest.on 'error', (e) =>
      mapResponseToResorce {statusCode:404}, resource, start
      sendUrlStatus resource.status_code
      @cacheStatusCode resource.uri, resource.status_code
      @storeResource resource

    clientRequest.end()

  lookup: (resource, sendUrlStatus) ->

    # fetching from the cache
    @resourceCache.lookup resource.uri, (err, statusCode) =>
      if err? then throw new Error err

      if statusCode?
        # send back the cached URL status
        sendUrlStatus statusCode
      else
        # fetch from repository
        @resourceRepository.findOne {uri:resource.uri}, (err, res) =>
          if err? then throw new Error err

          if res?
            @cacheStatusCode res.uri, res.status_code
            sendUrlStatus res.status_code
          else
            # crawl the new URL
            @crawlUrl resource, sendUrlStatus

module.exports = Crawler