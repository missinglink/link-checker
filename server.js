/**
 * server
 *
 *
 **/
var express = require('express');
var url = require('url');
var http = require('http');
var app = express();

app.use(app.router);

app.get('/check', function(req, res){
    var links = url.parse(req.url, true).query.links;    
    if (links === undefined) {
        res.writeHead(400, {'Content-Type':'text/plain'});
        res.end('links must be specified\n');
    } else {
        var checker = require('./checker').linksStatus(JSON.parse(links), function(status) {
console.log(status);
            
            if(0 === status.invalidLinks.length) {
                res.writeHead(302, {'Content-Type':'text/plain'});
            } else {
                res.writeHead(200, {'Content-Type':'text/plain'});
                res.end(status.invalidLinks);
            }
        });
    }
});
app.listen(3000);