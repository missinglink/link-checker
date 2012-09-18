var myApp = {
    version : 0.1,
    dataFormat : 'JSON',
//    defaultHTTPContentType : { 'Content-Type' : 'text/plain' },
    redisClient : undefined,
    socketIo : undefined,
    
    checkLinkEvent : 'link.add',
    linkStatus     : 'link.status',
    
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
            this.sendLinkStatus(link, res.StatusCode);

            // and store it into redis as cache for future requests
            this.redisClient.set(link, res.statusCode);
        });

        req.end();
    },
    
    // emit the link status on the socket
    sendLinkStatus : function(link, status) {
        this.socketIo.emit(this.linkStatus,
            {'link' : link, 'status' : status }
        );
    },
    
    checkLink : function(link) {
        this.redisClient.get(link, function(err, reply) {
            if (err) {
                console.log('Error: ' + err);
            }
console.log('reply');                        
console.log(reply);                        
            // the link is not present into redis
            if (reply === null) {
                this.crawlLink(link);
            } else {
                this.sendLinkStatus(link, res.StatusCode);
            }
        });
    },
    
    // initialize and connect to a REDIS server
    initRedis : function() {
        var redis = require('redis');
        var redisClient  = redis.createClient();
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
        socketIo.set( 'log level', 0 );
    },
    
    //listen to emits on the socket
    listen : function() {
        this.socketIo.on(this.checkLinkEvent, function(data){
console.log(data);
            if (undefined !== data.href) {
                this.checkLink(data.href);
            }
        });
    }
};

myApp.initRedis();
myApp.initSocketIo();
myApp.listen();