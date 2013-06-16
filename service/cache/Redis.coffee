redis = require 'redis'

config = require 'src/config/common'


class RedisCache

  
  redisClient = undefined


  init: () ->
    @redisClient = redis.createClient config.redis.port, config.redis.host
    throw new Error 'impossible to connect to redis' unless @redisClient?

    @redisClient.on 'error', (err) -> console.log err, 'REDIS ERROR'
    @redisClient.on 'connect', -> console.log "Connected to REDIS: #{config.redis.host}:#{config.redis.port}"
    @redisClient.on 'ready', -> console.log "REDIS connection ready"

    if config.redis.password?
      @redisClient.auth config.redis.password, (err) ->
        if err?
          console.log err, 'REDIS ERROR'
        else
          console.log "REDIS authenticated"



  save: (uri, statusCode, callback) ->
    @redisClient.set uri, statusCode, callback


  lookup: (requestedUrl, callback) ->
    @redisClient.get requestedUrl, callback


module.exports = new RedisCache
