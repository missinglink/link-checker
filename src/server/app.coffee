socketIO = require 'socket.io'
Crawler  = require 'service/Crawler'
Resource = require 'model/Resource'
cache    = require 'service/cache/Redis'

cache.init()

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
db = require '../config/db'
db.init app

#init socket.io
io = socketIO.listen 3000
io.set 'log level', 0

#listen on connection
io.on 'connection', (socket) ->

  originDomain = socket.manager.handshaken[socket.id].headers.origin

  socket.on 'url.add', (data) ->

    if data?.href?

      requestedUrl = Resource.filterAnchors data.href

      # TODO 
      # add the request host as hostname if the uri is relative

      # responde via socket
      sendUrlStatus = (resource) ->
        socket.emit 'url.status', 'url': data.href, 'status': resource.statusCode
      
      # store the uri
      storeUrl = (resource) -> cache.save resource

      lookupCallback = (err, resource) ->
        if err? then throw new Error err

        if resource?
          # send back the cached URL status
          sendUrlStatus resource
        else
          resource = new Resource requestedUrl
          # crawl the new URL
          crawler = new Crawler
          crawler.crawlUrl resource, storeUrl, sendUrlStatus

      # fetching from persistence object
      cache.lookup requestedUrl, lookupCallback