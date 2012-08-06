
exports.crawl = function(link, callback) {
    var url = require('url').parse(link, true);
    var options = {
        hostname: url.hostname,
        port: (url.port)     ?   url.port    :   80,
        path: (url.path)    ?   url.path    :   '/',
        method: 'HEAD'
    };

    var req = require('http').request(options, function(res) {
console.log('res');
console.log(res.statusCode);
        callback(res);
    });
    
    req.end();
}