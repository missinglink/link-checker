should = require 'should'

DateMapper = require 'mapper/type/DateMapper'
MockClass  = require 'test/mocks/MockClass'

describe 'DateMapper', ->

  date = 'Fri Dec 07 2012 14:50:16 GMT+0000 (GMT)'

  model = DateMapper.unmarshall(date)
  it 'should unmarshall (data -> model)', ->
    ( model instanceof Date ).should.be.true
    model.toString().should.equal date

  it 'should marshall (model -> data)', ->
    DateMapper.marshall(model).should.eql date

  it 'should not marshall a NON Currency model', ->
    (-> DateMapper.marshall(new MockClass)).should.throw 'Invalid Model'