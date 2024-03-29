Resource       = require 'model/Resource'
ResourceMapper = require 'mapper/ResourceMapper'

today = new Date 2012, 11, 20
resourceData =
  status_code: 200
  hostname: 'www.yahoo.com'
  protocol: 'http:'
  path: '/index.html'
  uri: 'http://www.yahoo.com/index.html'
  http_version: '1.1'
  server: 'YWS'
  last_checked: today
  request_time: 234
  content_type: 'text/html'

describe 'ResourceMapper', ->
  
  describe 'unmarshall', ->

    model = ResourceMapper.unmarshall resourceData

    it 'should unmarshall (data -> model)', ->
      model.should.be.instanceof Resource
      model.uri.should.equal 'http://www.yahoo.com/index.html'
      model.status_code.should.equal 200
      model.hostname.should.equal 'www.yahoo.com'
      model.protocol.should.equal 'http:'
      model.path.should.equal '/index.html'
      model.http_version.should.equal '1.1'
      model.server.should.equal 'YWS'
      model.last_checked.should.equal today
      model.request_time.should.equal 234
      model.content_type.should.equal 'text/html'

# ------------------------------------------------------------------

  describe 'marshall', ->

    describe 'failures', ->

      call() for call in [null, undefined, false, '', NaN, -1, [], {}, new Object, () ->].map (invalid) ->
        () ->
          it "should not marshall #{invalid}", ->
            (-> ResourceMapper.marshall invalid).should.throw 'Invalid Resource'

    describe 'success', ->

      it 'should marshall (model -> data)', ->
        model = ResourceMapper.unmarshall resourceData
        ResourceMapper.marshall(model).should.eql resourceData
