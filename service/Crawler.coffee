http = require 'http'
https = require 'https'

Resource = require 'model/Resource'

ResourceMapper = require 'mapper/client/ResourceMapper'

ResourceRepository = require 'repository/Resource'

ResourceFilter = require 'filters/ResourceFilter'

Cache = require 'service/cache/Redis'

MAX_REDIRECTS = 10

class Crawler

  constructor: (resourceCache = Cache, resourceRepository = ResourceRepository, resourceMapper = ResourceMapper) ->
    throw new Error 'Invalid cache' unless resourceCache?
    throw new Error 'Invalid repository' unless resourceRepository?
    throw new Error 'Invalid mapper' unless resourceMapper?

    resourceCache.init()
    @resourceRepository = new resourceRepository
    @resourceCache = resourceCache
    @resourceMapper = resourceMapper
    
    @followRedirects = true
    @followAllRedirects = true

  cacheStatusCode: (uri, statusCode, callback) ->
    @resourceCache.save uri, statusCode, (err, data) ->
      if callback instanceof Function
        if err? then return callback err, null

        # @TODO WTF is ERROR(data)
        return callback new Error(data), null unless data is 'OK'

  storeResource: (resource, callback) ->
    @resourceRepository.insert resource, (err, data) ->
      if callback instanceof Function
        if err? then return callback err, null
        
        # @TODO WTF is ERROR(data)
        return callback new Error(data), null unless Array.isArray data

  crawlUrl: (resource, callback, prevResources=[], maxRedirects) ->
    return callback new Error('invalid resource'), null unless resource instanceof Resource
     
    # resource.method = 'HEAD'
    resource.method = 'GET'

    switch resource.protocol
      when 'http:' then httpModule = http
      when 'https:' then httpModule = https
      else return callback new Error('protocol not supported'), null

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

      if res.statusCode >= 300 and res.statusCode < 400 and (@followAllRedirects or @followRedirects)
        # follow redirects
        if res.headers.location
          if maxRedirects is 0 then return callback null, res.statusCode
          else
            return @lookup new Resource( ResourceFilter.filter(res.headers.location, resource.hostname) ),
              callback,
              prevResources,
              (maxRedirects-1)
        else
          return callback new Error('No location to redirect to specified'), null
      
      else
        for resource, index in prevResources
          if index is 0 then callback null, res.statusCode

          try resource = @resourceMapper.unmarshall res, resource, start
          catch error then console.log error
          @cacheStatusCode resource.uri, res.statusCode
          @storeResource resource

    clientRequest.on 'error', (e) =>
      try resource = @resourceMapper.unmarshall {statusCode:404}, resource, start
      catch error then console.log error
      callback null, resource.status_code
      @cacheStatusCode resource.uri, resource.status_code
      @storeResource resource

    clientRequest.end()

  lookup: (resource, callback, prevResources=[], maxRedirects = MAX_REDIRECTS) ->

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
            @crawlUrl resource, callback, prevResources, maxRedirects

module.exports = Crawler