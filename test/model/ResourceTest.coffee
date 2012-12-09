should = require 'should'
Resource = require 'model/Resource'
http = require 'http'

describe 'Resource', ->

  validUris = [
    'http://www.domain.com'
    'http://www.domain.com/test.php?hello=world'
    'www.domain.com'
    'www.domain.com:80'
    'https://www.domain.com:443'
    '12.32.34.254'
    'http://askubuntu.com/questions/12434534534/answers#comment12'
  ]

  invalidUrls = [
    'asdfsafsdfsdffds'
    'http:wwwsdf'
    '255.0.0.1'
    'http://%%%%%/sdfdgfsdfg'
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
      for url in validUris
        resource = new Resource url

    it 'should set the default protocol if not specified', ->
      resource = new Resource 'www.domain.com'
      resource.protocol.should.equal Resource.defaultProtocol

  describe 'setStatusCode', ->

    resource = new Resource validUris[0]

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

  describe 'setHTTPVersion', ->
    resource = new Resource validUris[0]
    it 'should set a valid version', ->
      resource.setHTTPVersion '1.1'
      resource.httpVersion.should.equal '1.1'

  describe 'setServer', ->
    resource = new Resource validUris[0]
    it 'should set a valid server', ->
      resource.setServer 'nginx'
      resource.server.should.equal 'nginx'

  describe 'setLastCheckingDate', ->

    resource = new Resource validUris[0]

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

  describe 'allowed()', ->
    it 'should not allow mailto links', ->
      Resource.allow('mailto:').should.be.false

    it 'should allow protocols http, https, ftp, //', ->
      Resource.allow('http://www.google.com').should.be.true
      Resource.allow('https://www.google.com').should.be.true
      Resource.allow('ftp://www.google.com').should.be.true
      Resource.allow('//ajax.google.com').should.be.true

  describe 'removeFragment()', ->
    it 'should add the original domain name to relative uri', ->

      uri1 = 'http://www.ex.com/index.php?postId=2#new-comment'
      uri2 = 'https://www.ex.com/#'

      Resource.removeFragment(uri1).should.equal 'http://www.ex.com/index.php?postId=2'
      Resource.removeFragment(uri2).should.equal 'https://www.ex.com/'

  describe 'addTrailingSlash', ->
    uri1 = '//cdnjs.org/jQuery/minified'
    uri2 = '//cdnjs.org/jQuery/minified/'
    it 'should always add a trailing slash when it is not present', ->
      Resource.addTrailingSlash(uri1).should.equal uri1 + '/'
      Resource.addTrailingSlash(uri1).should.equal uri1 + '/'

  describe 'getAbsoluteURI', ->
    dom1 = 'http://www.example.com/blog/'

    requested1 = '../comment.html'
    requested2 = '../../comment.html'
    requested3 = '.../comment.html'
    requested4 = 'about.html'
    requested5 = 'tutorial1/'
    requested6 = 'tutorial1/2.html'
    requested7 = '/'
    requested8 = '//www.internet.com'
    requested9 = '/experts/'
    requested10 = '../'
    requested11 = '../experts/'
    requested12 = '../../../'
    requested13 = './'
    requested14 = './about.html'
    requested15 = './alpha2/./../about.html'
    
    it 'should remove the relative part', ->
      conv = Resource.getAbsoluteURI
      conv(requested1, dom1).should.equal 'http://www.example.com/comment.html'
      conv(requested2, dom1).should.equal 'http://www.example.com/comment.html'
      conv(requested3, dom1).should.equal 'http://www.example.com/blog/.../comment.html'
      conv(requested4, dom1).should.equal 'http://www.example.com/blog/about.html'
      conv(requested5, dom1).should.equal 'http://www.example.com/blog/tutorial1/'
      conv(requested6, dom1).should.equal 'http://www.example.com/blog/tutorial1/2.html'
      conv(requested7, dom1).should.equal 'http://www.example.com/'
      conv(requested8, dom1).should.equal 'http://www.internet.com'
      conv(requested9, dom1).should.equal 'http://www.example.com/experts/'
      conv(requested10, dom1).should.equal 'http://www.example.com/'
      conv(requested11, dom1).should.equal 'http://www.example.com/experts/'
      conv(requested12, dom1).should.equal 'http://www.example.com/'
      conv(requested13, dom1).should.equal 'http://www.example.com/blog/'
      conv(requested14, dom1).should.equal 'http://www.example.com/blog/about.html'
      conv(requested15, dom1).should.equal 'http://www.example.com/blog/about.html'