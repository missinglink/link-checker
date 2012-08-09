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
    socket.on 'link.add', (data) -> redis.rpush 'link.queue', data.href

# Worker
worker = () ->
    redis.lpop 'link.queue', (err,url) ->
        if url?
            request { url: url, method: 'GET' }, (error, response, body) ->
                io.sockets.emit 'link.status',
                    href : url.toString(),
                    status: if response then response.statusCode else 404

    process.nextTick worker

worker()