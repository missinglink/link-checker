var constants = {
    checkLinkEvent : 'link.add',
    linkStatus     : 'link.status',
    dnsErrorStatus : 500,
    localhost      : 'localhost'
};

var crawler = {
    
    // crawl al link passed using an HTTP client
    crawlLink : function(link) {
        var defaultPort   = 80;
        var defaultMethod = 'HEAD';
//        var defaultProtocol = 'http';
        var url = require('url').parse(link, true);

        var httpClient = require('http');
            var options = {
                hostname: url.hostname,
                port: (url.port)    ?   url.port    :   defaultPort,
                path: (url.path)    ?   url.path    :   '/',
                method: defaultMethod
            };

        var clientRequest = httpClient.request(options, (function(response) {
            this.handleResponse(link, response.statusCode);
        }).bind(this));

        clientRequest.on('error', (function(e) {
            this.handleResponse(link, constants.dnsErrorStatus);
        }).bind(this));

        clientRequest.end();
    },
    
    // handle HTTP response in a central place
    handleResponse: function(link, statusCode) {
        broker.sendLinkStatus(link, statusCode);

        // and store it into redis as cache for future requests
        application.redisClient.set(link, statusCode);
    }
};

var checker = {
    checkLink : function(link) {
        application.redisClient.get(link, function(err, reply) {
            if (err) {
                console.log('Error: ' + err);
                throw err;
            }

            // the link is not present into redis
            if (reply === null) {
                crawler.crawlLink(link);
            } else {
                broker.sendLinkStatus(link, reply);
            }
        });
    }
};

var broker = {
    defaultSocketPort : 3000,
    socketIo : undefined,    
    socket : undefined,
    
    // initialize the broker
    init : function(socketPort) {
        this.defaultSocketPort = socketPort;
        this.initSocketIo();
        this.listen();
    },
    
    // emit the link status on the socket
    sendLinkStatus : function(link, status) {
        this.socket.emit(constants.linkStatus,
            {'link' : link, 'status' : status }
        );
    },
    
    // initialize the socket
    initSocketIo : function() {
        this.socketIo = require('socket.io').listen(this.defaultSocketPort);
        this.socketIo.set( 'log level', 0 );
    },
    
    // listen on client connection and client emits on the socket
    listen : function() {
        this.socketIo.on('connection', (function (socket) {

            this.socket = socket;
            socket.on(constants.checkLinkEvent, function(data) {

                if (undefined !== data.href) {
                    checker.checkLink(data.href);
                }
            });
        }).bind(this));
    }
};

var application = {
    redisClient : undefined,
    broker : undefined,
    
    // initialize the application
    init: function(broker, socketPort){
        broker.init(socketPort);
        this.broker = broker;
    },
    
    // initialize and connect to a REDIS server
    initRedis : function() {
        var redis = require('redis');
        var redisClient = redis.createClient();
        if (undefined === redisClient){
            console.log('impossible to connect to redis');
        } else {
            this.redisClient = redisClient;
        }
        
        // bind an error handler to the redisClient
        this.redisClient.on('error', function (err) {
            console.log('Error ' + err);
        });
    }
};

application.init(broker, 3000);
application.initRedis();

//// Mini Web Server
//var express = require('express');
//var http = require('http');
//var app     = express();
//var server  = http.createServer(app);
//app.use( '/', express.static(__dirname + '/public') );
//app.listen(3001);
