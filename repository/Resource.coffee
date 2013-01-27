Source         = require 'repository/source/mongo/Resource'
ResourceMapper = require 'mapper/ResourceMapper'

class ResourceRepository

  constructor: (source = Source, mapper = ResourceMapper) ->
    throw new Error 'Invalid param' unless source instanceof Function
    throw new Error 'Invalid param' unless mapper instanceof Function
    @source = source
    @mapper = mapper

  insert: (resource, callback) ->
    @source.insert @mapper.marshall(resource), callback

  findOne: (query, callback) ->
    @source.findOne query, callback

  findAll: (query, fields, options, callback) ->
    @gateway.find query, fields, options, (err, cursor) ->
      if err? then return callback err, null

      resources = []
      cursor.each (err, resourceData) =>
        if err? then callback err, null

        if resourceData? then resources.push @mapper.unmarshall resourceData
        else return callback null, resources

  remove: (query, callback) ->
    @source.remove query, callback

module.exports = ResourceRepository 