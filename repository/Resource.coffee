Source = require 'repository/source/mongo/Resource'

ResourceMapper = require 'mapper/ResourceMapper'


class ResourceRepository


  constructor: (source = Source, mapper = ResourceMapper) ->
    throw new Error 'Invalid source' unless source instanceof Function
    throw new Error 'Invalid mapper marshall' unless mapper?.marshall instanceof Function 
    throw new Error 'Invalid mapper unmarshall' unless mapper?.unmarshall instanceof Function
    @source = source
    @mapper = mapper


  insert: (resource, callback) ->
    @source.insert @mapper.marshall(resource), callback


  findOne: (query, callback) ->
    @source.findOne query, callback


  findAll: (query, fields, options, callback) ->
    @gateway.find query, fields, options, (err, cursor) ->
      return callback err, null if err?

      resources = []
      cursor.each (err, resourceData) =>
        return callback err, null if err?

        if resourceData? then resources.push @mapper.unmarshall resourceData
        else return callback null, resources


  remove: (query, callback) ->
    @source.remove query, callback


module.exports = ResourceRepository
