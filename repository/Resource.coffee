class ResourceRepository

  constructor: (source, mapper) ->
    throw new Error 'Invalid param' unless source? and source instanceof Function
    throw new Error 'Invalid param' unless mapper? and mapper instanceof Function
    @source = source
    @mapper = mapper

  save: (resource, callback) ->
    @source.save @mapper.marshall(resource), callback

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