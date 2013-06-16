http  = require 'http'
https = require 'https'

Resource = require 'model/Resource'

ResourceMapper = require 'mapper/client/ResourceMapper'

ResourceRepository = require 'repository/Resource'

ResourceFilter = require 'filters/ResourceFilter'

redisCache = require 'service/cache/Redis'

MAX_REDIRECTS = 10


class Crawler


  constructor: (resourceCache = redisCache, resourceRepository = ResourceRepository, resourceMapper = ResourceMapper) ->
    throw new Error 'Invalid cache' unless resourceCache?
    throw new Error 'Invalid repository' unless resourceRepository?
    throw new Error 'Invalid mapper unmarshall' unless resourceMapper?.unmarshall instanceof Function

    resourceCache.init()
    @resourceRepository = new resourceRepository
    @resourceCache = resourceCache
    @resourceMapper = resourceMapper

    @followRedirects = true
    @followAllRedirects = true


  cacheStatusCode: (uri, statusCode, callback) ->
    @resourceCache.save uri, statusCode, (err, data) ->
      return callback err, data if callback instanceof Function
    return


  storeResource: (resource, callback) ->
    @resourceRepository.insert resource, (err, data) ->
      if callback instanceof Function
        return callback err, null if err?
        return callback null, [] unless Array.isArray data
        return callback null, data
    return


  crawlUrl: (resource, prevResources = [], maxRedirects, callback) ->
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
      agent: false

    start = new Date

    req = httpModule.request options, (res) =>

      prevResources.push resource

      if 300 <= res.statusCode < 400 and (@followAllRedirects or @followRedirects)

        # follow redirects
        if res.headers.location?
          return callback null, res.statusCode if maxRedirects is 0

          # recursion
          return @lookup new Resource( ResourceFilter.filter(res.headers.location, resource.hostname) ), prevResources, maxRedirects-1, callback

        else

          return callback new Error('No location to redirect to specified'), null

      else
        for prevResource, index in prevResources
          if index is 0 then callback null, res.statusCode

          try prevResource = @resourceMapper.unmarshall res, prevResource, start
          catch error
            console.log error
            return callback error, null

          @cacheStatusCode prevResource.uri, res.statusCode
          @storeResource prevResource


    req.on 'error', (e) =>
      try resource = @resourceMapper.unmarshall {statusCode:404}, resource, start
      catch error
        console.log error
        return callback error, null

      @cacheStatusCode resource.uri, resource.status_code
      @storeResource resource

      return callback null, resource.status_code

    req.end()


  lookup: (resource, prevResources = [], maxRedirects = MAX_REDIRECTS, callback) ->
    @resourceCache.lookup resource.uri, (err, statusCode) =>
      return callback err, null if err?
      return callback null, statusCode if statusCode?

      @resourceRepository.findOne resource.uri, (err, res) =>
        return callback err, null if err?

        if res?
          @cacheStatusCode res.uri, res.status_code, callback
          return callback null, res.status_code

        else
          return @crawlUrl resource, prevResources, maxRedirects, callback

      return

    return


module.exports = Crawler