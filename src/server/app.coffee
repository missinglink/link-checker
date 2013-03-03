#require('nodetime').profile()

socketIO = require 'socket.io'

Crawler  = require 'service/Crawler'

Resource = require 'model/Resource'

ResourceFilter = require 'filters/ResourceFilter'

app = {}
env = process.env.NODE_ENV || 'development';

# init environment specific configurations
switch env
  when 'development'
    environment = require 'src/config/environment/development'
  when 'staging'
    environment = require 'src/config/environment/staging'
  when 'production'
    environment = require 'src/config/environment/production'
  else throw new Error 'environment ' + env + ' not defined'
environment app

# init database
db = require 'src/config/db'
db.init app

#init socket.io
io = socketIO.listen 3000
io.set 'log level', 0

crawlerService = new Crawler

#listen on connection
io.on 'connection', (socket) ->

  originDomain = socket.manager.handshaken[socket.id].headers.referer

  socket.on 'url.add', (data) ->

    if data?.href?
      
      # send response via socket
      sendUrlStatus = (err, statusCode) ->
        if err? then return console.log 'sendUrlStatus', err
        socket.emit 'url.status', 'url': data.href, 'status': statusCode

      if not Resource.isProtocolAllowed data.href then sendUrlStatus null, 200

      try resource = new Resource ResourceFilter.filter(data.href, originDomain)
      catch err then console.log 'ERROR', err

      crawlerService.lookup resource, sendUrlStatus