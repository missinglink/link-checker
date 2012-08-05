var redis = require('redis');
var client = redis.createClient();

client.on("error", function (err) {
	console.log("Error " + err);
});

//client.set("string key", "string val", redis.print);
//client.hset("hash key", "hashtest 1", "some value", redis.print);
//client.hset(["hash key", "hashtest 2", "some other value"], redis.print);
//client.hkeys("hash key", function (err, replies) {
//	console.log(replies.length + " replies:");
//	replies.forEach(function (reply, i) {
//		console.log("    " + i + ": " + reply);
//	});
//	client.quit();
//});

exports.links = function(links) {
	var invalidLinks = [];
	var validLinks = [];

	links.forEach(function(link) {
		client.get(link, function(err, reply) {
		if (reply === null) {
			storeLink(link);
		} else {
			if (reply !== 200 || reply !== 301) {
				invalidLinks.push(link);
			} else {
				validLinks.push(link);
			}
		}
// reply is null when the key is missing
console.log(reply);
		});
	});
}

var storeLink = function(link, retStatusCode) {
	var crawler = require('./crawler');
	crawler.crawl(link, function(statusCode) {
		client.set(link,statusCode);
		retStatusCode = statusCode;
	});
};
