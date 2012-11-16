socketIO = require 'socket.io'
Crawler  = require '../../service/Crawler'
Resource = require '../../model/Resource'
storage  = require '../../service/storage/Redis'

storage.init()

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
      storeUrl = (resource) -> storage.save resource

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
      storage.lookup requestedUrl, lookupCallback