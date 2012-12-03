socketIO = require 'socket.io'
Crawler  = require 'service/Crawler'
Resource = require 'model/Resource'
Cache    = require 'service/cache/Redis'
Source   = require 'repository/source/mongo/Resource'
ResourceMapper = require 'mapper/ResourceMapper'
ResourceRepository = require 'repository/Resource'

Cache.init()

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

resRepo = new ResourceRepository Source, ResourceMapper
crawlerService = new Crawler resRepo, Cache

#listen on connection
io.on 'connection', (socket) ->

  originDomain = socket.manager.handshaken[socket.id].headers.referer

  socket.on 'url.add', (data) ->

    if data?.href?
      
      absoluteUri = Resource.getAbsoluteURI data.href, originDomain
      cleanUri = Resource.removeFragment absoluteUri
      cleanUri = Resource.addTrailingSlash cleanUri

      # responde via socket
      sendUrlStatus = (statusCode) ->
        socket.emit 'url.status', 'url': data.href, 'status': statusCode

      sendUrlStatus 200 unless Resource.allow data.href

      crawlerService.lookup cleanUri, sendUrlStatus