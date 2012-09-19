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
            method: defaultMethod
        };

        var req = httpClient.request(options, function(res) {
console.log('res');
console.log(res.statusCode);
            myApp.sendLinkStatus(link, res.StatusCode);

            // and store it into redis as cache for future requests
            myApp.redisClient.set(link, res.statusCode);
        });

        req.end();
    }
};

var checker = {
    checkLink : function(link) {
        myApp.redisClient.get(link, function(err, reply) {
            if (err) {
                console.log('Error: ' + err);
            }
                  
            // the link is not present into redis
            if (reply === null) {
                crawler.crawlLink(link);
            } else {
console.log('link: ' + link);                
console.log('reply: ' + reply);                
                myApp.sendLinkStatus(link, reply);
            }
        });
    }
};

var myApp = {
    
    redisClient : undefined,
    socketIo : undefined,    
    socket : undefined,
    
    // emit the link status on the socket
    sendLinkStatus : function(link, status) {
console.log('sendLinkStatus');        
console.log('link: ' + link);        
console.log('status: ' + status);        
        
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
        var defaultSocketPort = 3000;
        this.socketIo = require('socket.io').listen(defaultSocketPort);
//        this.socketIo.set( 'log level', 0 );
    },
    
    //listen on connection and emits on the socket
    listen : function() {
        this.socketIo.on('connection', function (socket) {
            myApp.socket = socket;
            socket.on(constants.checkLinkEvent, function(data) {
console.log(data);
                if (undefined !== data.href) {
                    checker.checkLink(data.href);
                }
            });
        });
    }
};

myApp.initRedis();
myApp.initSocketIo();
myApp.listen();