var constants = {
    checkUrlEvent : 'url.add',
    urlStatus     : 'url.status',
    dnsErrorStatus : 500,
    localhost      : 'localhost'
};

var crawler = {
    
    // crawl an url passed using an HTTP client
    crawlUrl : function(url) {     
        var defaultPort   = 80;
        var defaultMethod = 'GET';
//        var defaultProtocol = 'http';
        var urlParts = require('url').parse(url, true);

        var httpClient = require('http');
            var options = {
                hostname: urlParts.hostname,
                port: (urlParts.port)    ?   urlParts.port    :   defaultPort,
                path: (urlParts.path)    ?   urlParts.path    :   '/',
                method: defaultMethod
            };

        var clientRequest = httpClient.request(options, (function(response) {
            this.handleResponse(url, response.statusCode);
        }).bind(this));

        clientRequest.on('error', (function(e) {
            this.handleResponse(url, constants.dnsErrorStatus);
        }).bind(this));

        clientRequest.end();
    },
    
    // handle HTTP response in a central place
    handleResponse: function(url, statusCode) {
        broker.sendUrlStatus(url, statusCode);

        // and store it into redis as cache for future requests
        application.redisClient.set(url, statusCode);
    }
};

var checker = {
    checkUrl : function(url) {
        application.redisClient.get(url, function(err, reply) {
            if (err) {
                console.log('Error: ' + err);
                throw err;
            }

            // the url is not present into redis
            if (reply === null) {
                crawler.crawlUrl(url);
            } else {
                broker.sendUrlStatus(url, reply);
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
    
    // emit the url status on the socket
    sendUrlStatus : function(url, status) {
        this.socket.emit(constants.urlStatus,
            {'url' : url, 'status' : status }
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
            socket.on(constants.checkUrlEvent, function(data) {

                if (undefined !== data.href) {
                    checker.checkUrl(data.href);
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




//console.log(require('http').STATUS_CODES);