var util = require('util');
var redis = require('redis');
var redisClient = redis.createClient();

redisClient.on("error", function (err) {
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

exports.linksStatus = function(links, callback) {
    var invalidLinks = [];
    var validLinks = [];
    for ( var i = 0, l = links.len; i < l; i++) {
        var link = links[i];
        redisClient.get(link, function(err, reply) {
            if(err) {
                util.log('Error: ' + err);
            }
console.log('reply');                        
console.log(reply);                        
            // the link is not present into redis
            if (reply === null) {
                var crawler = require('./crawler');
                crawler.crawl(link, function(res) {           
                    redisClient.set(link,res.statusCode);
                    reply = res.statusCode;
                });
            }
            
            if (reply >= 400) {
                invalidLinks.push(link);
            } else {
                validLinks.push(link);
            }
        });
        callback({'validLinks': validLinks, 'invalidLinks': invalidLinks});
    }
redisClient.quit();
}
