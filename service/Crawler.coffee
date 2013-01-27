http = require 'http'
https = require 'https'

Resource = require 'model/Resource'

ResourceRepository = require 'repository/Resource'

ResourceFilter = require 'filters/ResourceFilter'

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

  cacheStatusCode: (uri, statusCode, callback) ->
    @resourceCache.save uri, statusCode, (err, data) ->
      if err? then return callback err, null
      return callback new Error data, null unless data is 'OK'

  storeResource: (resource, callback) ->
    @resourceRepository.insert resource, (err, data) ->
      if err? then return callback err, null
      return callback new Error data, null unless Array.isArray data

  crawlUrl: (resource, callback, prevResources=[]) ->
    return callback new Error 'invalid resource', null unless resource instanceof Resource
     
    # resource.method = 'HEAD'
    resource.method = 'GET'

    switch resource.protocol
      when 'http:' then httpModule = http
      when 'https:' then httpModule = https
      else return callback new Error 'protocol not supported', null

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
      prevResources.push resource

      # follow redirects
      if res.statusCode >= 300 and res.statusCode < 400 and (@followAllRedirects or @followRedirect) and res.headers.location
        if @redirectsFollowed >= MAX_REDIRECTS
          callback null, res.statusCode
        else
          @redirectsFollowed += 1
          @lookup new Resource( ResourceFilter.filter(res.headers.location, resource.hostname) ),
            callback,
            prevResources
      
      else
        for resource, index in prevResources
          if index is 0 then callback null, res.statusCode
          mapResponseToResource res, resource, start
          @cacheStatusCode resource.uri, res.statusCode, callback
          @storeResource resource, callback

    clientRequest.on 'error', (e) =>
      mapResponseToResource {statusCode:404}, resource, start
      callback null, resource.status_code
      @cacheStatusCode resource.uri, resource.status_code, callback
      @storeResource resource, callback

    clientRequest.end()

  lookup: (resource, callback, prevResources=[]) ->

    @resourceCache.lookup resource.uri, (err, statusCode) =>
      if err? then return callback err, null

      if statusCode? then callback null, statusCode

      else
        @resourceRepository.findOne {uri:resource.uri}, (err, res) =>
          if err? then return callback err, null

          if res?
            @cacheStatusCode res.uri, res.status_code, callback
            callback null, res.status_code

          else
            @crawlUrl resource, callback, prevResources

module.exports = Crawler