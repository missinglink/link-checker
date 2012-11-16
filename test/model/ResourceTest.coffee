should = require 'should'
Resource = require '../../model/Resource'
http = require 'http'

describe 'Resource', ->

  validUrls = [
    'http://www.domain.com'
    'http://www.domain.com/test.php?hello=world'
    'www.domain.com'
    'www.domain.com:80'
    'https://www.domain.com:443'
    '12.32.34.254'
  ]

  invalidUrls = [
    'asdfsafsdfsdffds'
    'http:wwwsdf'
    '255.0.0.1'
  ]

  describe 'constructor', ->

    it 'should not accept invalid parameters', ->
      ( -> new Resource()).should.throw 'Invalid uri'
      ( -> new Resource null).should.throw 'Invalid uri'
      ( -> new Resource undefined).should.throw 'Invalid uri'
      ( -> new Resource false).should.throw 'Invalid uri'
      ( -> new Resource []).should.throw 'Invalid uri'
      ( -> new Resource {}).should.throw 'Invalid uri'
      ( -> new Resource 1.111).should.throw 'Invalid uri'
      for url in invalidUrls
        ( -> new Resource url).should.throw 'Invalid uri'

    it 'should accept valid parameters', ->
      for url in validUrls
        resource = new Resource url

    it 'should set the default protocol if not specified', ->
      resource = new Resource 'www.domain.com'
      resource.protocol.should.equal Resource.defaultProtocol

  describe 'setStatusCode', ->

    resource = new Resource validUrls[0]

    it 'should not accept invalid parameters', ->
      ( -> resource.setStatusCode()).should.throw 'Invalid status code'
      ( -> resource.setStatusCode(null)).should.throw 'Invalid status code'
      ( -> resource.setStatusCode(undefined)).should.throw 'Invalid status code'
      ( -> resource.setStatusCode(false)).should.throw 'Invalid status code'
      ( -> resource.setStatusCode([])).should.throw 'Invalid status code'
      ( -> resource.setStatusCode({})).should.throw 'Invalid status code'
      ( -> resource.setStatusCode('status:OK')).should.throw 'Invalid status code'
      ( -> resource.setStatusCode(1.111)).should.throw 'Invalid status code'
      ( -> resource.setStatusCode(600)).should.throw 'Invalid status code'

    it 'should accept valid paramenter', ->
      for status in Object.keys http.STATUS_CODES
        resource.setStatusCode(status).should.equal status

  describe 'setLastCheckingDate', ->

    resource = new Resource validUrls[0]

    it 'should not accept invalid parameters', ->
      ( -> resource.setLastCheckingDate()).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate(null)).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate(undefined)).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate(false)).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate([])).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate({})).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate('status:OK')).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate(1.111)).should.throw 'Invalid date'
      ( -> resource.setLastCheckingDate(600)).should.throw 'Invalid date'

    it 'should accept valid paramenter', ->
      now = new Date()
      resource.setLastCheckingDate(now).should.equal now

