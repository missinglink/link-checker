MongoGateway = require 'lib/MongoGateway'

collectionName = 'resources'


class Resource


  @insert: (resource, callback) ->
    MongoGateway.insert collectionName, resource, callback


  @findOne: (uri, callback) ->
    MongoGateway.findOne collectionName, {uri: uri}, callback


  @findAll: (query, fields, options, callback) ->
    MongoGateway.find collectionName, query, fields, options, callback


  @remove: (query, callback) ->
    MongoGateway.remove collectionName, query, callback


module.exports = Resource 