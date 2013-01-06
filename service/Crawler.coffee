http = require 'http'
https = require 'https'

Resource = require 'model/Resource'

ResourceRepository = require 'repository/Resource'

Cache = require 'service/cache/Redis'

mapResponseToResource = (response, resource, start) ->
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

MAX_REDIRECTS = 10

class Crawler

  constructor: (resourceCache = Cache, resourceRepository = ResourceRepository) ->
    throw new Error 'Invalid param' unless resourceCache?
    throw new Error 'Invalid param' unless resourceRepository?

    resourceCache.init()
    @resourceRepository = new resourceRepository
    @resourceCache = resourceCache
    
    @redirectsFollowed = 0
    @followRedirects = true
    @followAllRedirects = true
    @resources = {}

  filterInput: (href, originDomain) ->
    absoluteUri = Resource.getAbsoluteURI href, originDomain

    return new Resource absoluteUri, [
      Resource.addDefaultProtocol
      Resource.removeFragment
      Resource.lowerCase
      Resource.useCanonicalSlashes
    ]

  cacheStatusCode: (uri, statusCode) ->
    @resourceCache.save uri, statusCode

  storeResource: (resource) ->
    @resourceRepository.save resource, (err) ->
      if err? then throw new Error err

  # crawl an url passed using an HTTP client
  crawlUrl: (resource, sendUrlStatus, prevResources=[]) ->
    throw new Error 'invalid resource type' unless resource instanceof Resource
    
    # resource.method = 'HEAD'
    resource.method = 'GET'

    switch resource.protocol
      when 'http:' then httpModule = http
      when 'https:' then httpModule = https
      else throw new Error 'protocol not supported'

    options =
      protocol: resource.protocol
      hostname: resource.hostname
      port: resource.port
      method: resource.method
      path: resource.path
      headers: {}
      agent: httpModule.globalAgent

    start = Date.now()
    clientRequest = httpModule.request options, (res) =>
      
      # populate the redirection resource history
      prevResources.push resource

      # follow redirects
      if res.statusCode >= 300 and res.statusCode < 400 and (@followAllRedirects or @followRedirect) and res.headers.location
        if @redirectsFollowed >= MAX_REDIRECTS
          sendUrlStatus res.statusCode
        else
          @redirectsFollowed += 1
          @lookup @filterInput( res.headers.location, resource.hostname ), sendUrlStatus, prevResources
      
      else
        for resource, index in prevResources
          # only the first resource must be notified via socket
          if index is 0 then sendUrlStatus res.statusCode

          mapResponseToResource res, resource, start
          @cacheStatusCode resource.uri, res.statusCode
          @storeResource resource

    clientRequest.on 'error', (e) =>
      mapResponseToResource {statusCode:404}, resource, start
      sendUrlStatus resource.status_code
      @cacheStatusCode resource.uri, resource.status_code
      @storeResource resource

    clientRequest.end()

  lookup: (resource, sendUrlStatus, prevResources=[]) ->

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
            @crawlUrl resource, sendUrlStatus, prevResources

module.exports = Crawler