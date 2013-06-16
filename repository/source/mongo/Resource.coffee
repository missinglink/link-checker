MongoGateway = require 'lib/MongoGateway'

collectionName = 'resources'


class Resource


  @insert: (resource, callback) ->
    MongoGateway.insert collectionName, resource, callback


  @findOne: (query, callback) ->
    MongoGateway.findOne collectionName, query, callback


  @findAll: (query, fields, options, callback) ->
    MongoGateway.find collectionName, query, fields, options, callback


  @remove: (query, callback) ->
    MongoGateway.remove collectionName, query, callback


module.exports = Resource 