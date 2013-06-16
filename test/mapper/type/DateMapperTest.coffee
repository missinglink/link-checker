DateMapper = require 'mapper/type/DateMapper'
MockClass  = require 'test/mocks/MockClass'

describe 'DateMapper', ->

  date = '2012-12-14T14:25:44.233Z'
  model = DateMapper.unmarshall(date)

  it 'should unmarshall (data -> model)', ->
    model.should.be.instanceof Date
    model.toISOString().should.equal date

  it 'should marshall (model -> data)', ->
    DateMapper.marshall(model).should.eql date

  it 'should not marshall a NON Currency model', ->
    (-> DateMapper.marshall(new MockClass)).should.throw 'Invalid Model'