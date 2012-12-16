should = require 'should'

Resource       = require 'model/Resource'
ResourceMapper = require 'mapper/ResourceMapper'
MockClass      = require 'test/mocks/MockClass'

describe 'ResourceMapper', ->

  resourceData =
    uri: 'http://www.yahoo.com/index.html'
    statusCode: 200
    hostname: 'www.yahoo.com'
    protocol: 'http:'
    path: '/index.html'
    httpVersion: '1.1'
    server: 'YWS'
    lastCheckingDate: new Date 2012, 11, 20

  model = ResourceMapper.unmarshall(resourceData)
  it 'should unmarshall (data -> model)', ->
    model.should.be.instanceof Resource

  it 'should marshall (model -> data)', ->
    ResourceMapper.marshall(model).should.eql resourceData

  it 'should not marshall a NON Currency model', ->
    (-> ResourceMapper.marshall(new MockClass)).should.throw 'Invalid Model'