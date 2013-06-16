socketIO = require 'socket.io'

Crawler  = require 'service/Crawler'

Resource = require 'model/Resource'

ResourceFilter = require 'filters/ResourceFilter'

config = require 'src/config/common'

app = {}

# init database
db = require 'src/config/db'
db.init app

#init socket.io
io = socketIO.listen config.websocket.port
io.set 'log level', 0

crawlerService = new Crawler

#listen on connection
io.on 'connection', (socket) ->

  originDomain = socket.manager.handshaken[socket.id].headers.referer

  socket.on 'url.add', (data) ->

    if data?.href?
      
      # send response via socket
      sendUrlStatus = (err, statusCode) ->
        return console.log 'sendUrlStatus', err if err?
        socket.emit 'url.status', 'url': data.href, 'status': statusCode

      if not Resource.isProtocolAllowed data.href
        sendUrlStatus null, 200

      try resource = new Resource ResourceFilter.filter(data.href, originDomain)
      catch err then console.log 'ERROR', err

      crawlerService.lookup resource, null, null, sendUrlStatus
