DateMapper = require 'mapper/type/DateMapper'
MockClass  = require 'test/mocks/MockClass'

describe 'DateMapper', ->

  date = 1355495144233
  model = DateMapper.unmarshall(date)

  it 'should unmarshall (data -> model)', ->
    ( model instanceof Date ).should.be.true
    model.getTime().should.equal date

  it 'should marshall (model -> data)', ->
    DateMapper.marshall(model).should.eql date

  it 'should not marshall a NON Currency model', ->
    (-> DateMapper.marshall(new MockClass)).should.throw 'Invalid Model'