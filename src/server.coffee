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

      # Add to processing queue
      redis.rpush 'request.queue.index', id

# Worker
worker = () ->

  # Try to load a request id from the queue
  redis.lpop 'request.queue.index', (err,reqid) ->
    if reqid?
    
      # Load request
      redis.hgetall util.format('request.%s',reqid), (err,req) ->
        if req?
        
          # Cache lookup
          redis.get util.format('url.status.%s',req.href), (err,status) ->
          
            # Cache hit
            if status?

              # Send reply to client
              io.sockets.emit 'link.status',
                href : req.href,
                status: status

            # Cache miss
            else

              # Make HTTP request
              request { url: req.href, method: 'GET' }, (error, response, body) ->

                # Get status code
                status = if response then response.statusCode else 404

                # Persist url status code
                redis.set util.format('url.status.%s',req.href), status, (err,reply) ->

                  # Send reply to client
                  io.sockets.emit 'link.status',
                    href : req.href,
                    status: status

  # Loop
  process.nextTick worker

worker()