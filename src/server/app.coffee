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

  originDomain = socket.manager.handshaken[socket.id].headers.origin

  socket.on 'url.add', (data) ->

    if data?.href?

      requestedUrl = Resource.filterAnchors data.href

      # TODO 
      # add the request host as hostname if the url is relative

      # responde via socket
      sendUrlStatus = (statusCode) ->
        socket.emit 'url.status', 'url': data.href, 'status': statusCode

      crawlerService.lookup requestedUrl, sendUrlStatus