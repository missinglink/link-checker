redis = require 'redis'

class Storage

  redisClient = undefined

  init: () =>
    @redisClient = redis.createClient()
    console.log 'impossible to connect to redis' unless redisClient?

    @redisClient.on 'error', (err) ->
      console.log 'REDIS error: ' + err

  save: (resource) =>
    hash =
      "statusCode": resource.statusCode 
      "hostname": resource.hostname 
      "protocol": resource.protocol
      "port": resource.port
      "path": resource.path
      "lastCheckingDate": resource.lastCheckingDate
    console.log hash
    @redisClient.hmset resource.uri, hash, (err, data) ->
      if err? then throw new Error err

  lookup: (requestedUrl, callback) =>
    @redisClient.hgetall requestedUrl, callback

module.exports = new Storage