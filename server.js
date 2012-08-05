/**
 * server
 *
 *
 **/
var express = require('express');
var url = require('url');
var app = express();

app.use(app.router);

app.get('/check', function(req, res){
	var checker = require('./checker');
//console.log(req.links);
	if (url.parse(req.url, true).query.links === undefined) {
		noLinks(res);
	} else {
		var links = checker.links(url.parse(req.url, true).query.links);
	}
console.log(links);
});
app.listen(3000);


var noLinks = function(res) {
	res.writeHead(400, {'Content-Type':'text/plain'});
	res.end('links must be specified\n');
}
