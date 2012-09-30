var constants = {
    checkLinkEvent : 'link.add',
    linkStatus     : 'link.status'
};

var crawler = {
    crawlLink : function(link) {
        var httpClient    = require('http');
        var defaultPort   = 80;
        var defaultMethod = 'HEAD';
//        var defaultProtocol = 'http';
        
        var url = require('url').parse(link, true);
        var options = {
            hostname: url.hostname,
            port: (url.port)    ?   url.port    :   defaultPort,
            path: (url.path)    ?   url.path    :   '/',
            method: defaultMethod,
            'User-Agent' : '*'
        };

        var req = httpClient.request(options, function(res) {        
            application.sendLinkStatus(link, res.statusCode);

            // and store it into redis as cache for future requests
            application.redisClient.set(link, res.statusCode);
        });

        req.end();
    }
};

var checker = {
    checkLink : function(link) {
        application.redisClient.get(link, function(err, reply) {
            if (err) {
                console.log('Error: ' + err);
            }

            // the link is not present into redis
            if (reply === null) {
                crawler.crawlLink(link);
            } else {
                application.sendLinkStatus(link, reply);
            }
        });
    }
};

var application = {
    defaultSocketPort : 3000,
    redisClient : undefined,
    socketIo : undefined,    
    socket : undefined,
    
    init: function(socketPort){
        this.defaultSocketPort = socketPort;
    },
    
    // emit the link status on the socket
    sendLinkStatus : function(link, status) {
        this.socket.emit(constants.linkStatus,
            {'link' : link, 'status' : status }
        );
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
    },
    
    // initialize the socket
    initSocketIo : function() {
        this.socketIo = require('socket.io').listen(this.defaultSocketPort);
        this.socketIo.set( 'log level', 0 );
    },
    
    //listen on connection and emits on the socket
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

application.init(3000);
application.initRedis();
application.initSocketIo();
application.listen();

//// Mini Web Server
//var express = require('express');
//var http = require('http');
//var app     = express();
//var server  = http.createServer(app);
//app.use( '/', express.static(__dirname + '/public') );
//app.listen(3001);
