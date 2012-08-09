# Configure Server
express = require 'express'
request = require 'request'
util = require 'util'
app = express()
server = require('http').createServer app
io = require('socket.io').listen server
server.listen 3000

# Express Routes
app.use app.router
app.use '/', express.static __dirname + '/../public'

# Redis Setup
redis = require('redis').createClient()
redis.on 'error', (err) -> console.log err

# Web Sockets
io.sockets.on 'connection', (socket) ->
  socket.on 'link.add', (data) ->
  
    # Get new request primary id
    redis.incr 'request.index', (err,id) ->

      # Persist request
      redis.hmset util.format('request.%s',id), data

      # Hit cache
      redis.get util.format('url.%s',data.href), (err,respid) ->
        if respid?
        
          # Load the response data
          redis.hgetall util.format('response.%s',respid), (err,response) ->
          
            # Send reply to client
            io.sockets.emit 'link.status',
              href : data.href,
              status: if response then response.statusCode else 404
          
        else

          # Add to processing queue
          redis.rpush 'request.queue.index', id

# Worker
worker = () ->

  # Try to load a request id from the queue
  redis.lpop 'request.queue.index', (err,reqid) ->
    if reqid?
    
      # Load the request data
      redis.hgetall util.format('request.%s',reqid), (err,req) ->
        if req?
        
          # Make HTTP request
          request { url: req.href, method: 'GET' }, (error, response, body) ->
          
            # Get new response primary id
            redis.incr 'response.count', (err,incr) ->
            
              # Persist HTTP response
              redis.hmset util.format('response.%s',incr), response, (err,reply) ->

                # Maintain url index with response ids
                  redis.set util.format('url.%s',req.href), incr, (err,reply) ->
                  
                    # Send reply to client
                    io.sockets.emit 'link.status',
                      href : req.href,
                      status: if response then response.statusCode else 404

    process.nextTick worker

worker()