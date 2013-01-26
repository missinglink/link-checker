class DateMapper

  @marshall: (model) ->

    throw new Error 'Invalid Model' unless model instanceof Date
    
    return model.toISOString()

  @unmarshall: (data) ->

    return new Date data

module.exports = DateMapper