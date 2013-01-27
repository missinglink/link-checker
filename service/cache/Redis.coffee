redis = require 'redis'

class RedisCache

  redisClient = undefined

  init: () =>
    @redisClient = redis.createClient()
    throw new Error 'impossible to connect to redis' unless @redisClient?

    @redisClient.on 'error', (err) ->
      throw new Error 'REDIS error: ' + err

  save: (uri, statusCode, callback) =>
    @redisClient.set uri, statusCode, callback

  lookup: (requestedUrl, callback) =>
    @redisClient.get requestedUrl, callback

module.exports = new RedisCache