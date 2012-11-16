redis    = require 'redis'
socketIO = require 'socket.io'
Crawler  = require '../../service/Crawler'

#init redis
redisClient = redis.createClient()
console.log 'impossible to connect to redis' unless redisClient?

# error handling
redisClient.on 'error', (err) ->
  console.log 'REDIS error: ' + err

#init socket.io
io = socketIO.listen 3000
io.set 'log level', 0

#listen on connection
io.on 'connection', (socket) ->

  #listen to url added
  socket.on 'url.add', (data) ->

    if data?.href?

      # handle socket response      
      sendUrlStatus = (url, status) ->
        socket.emit 'url.status', 'url': url, 'status': status
      
      # handle persistence
      storeUrl = (url, statusCode) ->
        redisClient.set url, statusCode

      # fetching from persistence object
      redisClient.get data.href, (err, reply) ->

        unless reply?
          # crawl the new URL
          crawler = new Crawler
          crawler.crawlUrl data.href, storeUrl, sendUrlStatus
        else
          # send back the cached URL status
          sendUrlStatus data.href, reply