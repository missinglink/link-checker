should = require 'should'

Resource       = require 'model/Resource'
ResourceMapper = require 'mapper/ResourceMapper'
MockClass      = require 'test/mocks/MockClass'

describe 'ResourceMapper', ->

  today = new Date 2012, 11, 20

  resourceData =
    uri: 'http://www.yahoo.com/index.html'
    statusCode: 200
    hostname: 'www.yahoo.com'
    protocol: 'http:'
    path: '/index.html'
    httpVersion: '1.1'
    server: 'YWS'
    lastCheckingDate: today

  model = ResourceMapper.unmarshall(resourceData)
  it 'should unmarshall (data -> model)', ->
    model.should.be.instanceof Resource
    model.uri.should.equal 'http://www.yahoo.com/index.html'
    model.statusCode.should.equal 200
    model.hostname.should.equal 'www.yahoo.com'
    model.protocol.should.equal 'http:'
    model.path.should.equal '/index.html'
    model.httpVersion.should.equal '1.1'
    model.server.should.equal 'YWS'
    model.lastCheckingDate.should.equal today

  it 'should marshall (model -> data)', ->
    ResourceMapper.marshall(model).should.eql resourceData

  it 'should not marshall a NON Currency model', ->
    (-> ResourceMapper.marshall(new MockClass)).should.throw 'Invalid Model'