
# Configure Server
express = require 'express'
app = express()
server = require('http').createServer app
io = require('socket.io').listen server
server.listen 3000

# Express Routes
app.use app.router
app.use '/', express.static __dirname + '/../public'

# Redis Setup
redis = require('redis').createClient()
redis.on 'error', (err) ->
    console.log 'error event - ' + client.host + ':' + client.port + ' - ' + err

# Web Sockets
io.sockets.on 'connection', (socket) ->
    socket.on 'link.add', (data) ->
        redis.rpush 'link.queue', data.href

# Worker
worker = () ->
    redis.lpop 'link.queue', (err,url) ->
        if url?

            urlObj = require('url').parse url.toString(), true
            options = {
                hostname: urlObj.hostname,
                port: (urlObj.port)    ?   urlObj.port    :   80,
                path: (urlObj.path)    ?   urlObj.path    :   '/',
                method: 'GET'
            }

            req = require('http').request options, (res) ->
                io.sockets.emit 'link.status', { href : url.toString(), status: res.statusCode }

            req.end();

    process.nextTick worker

worker()