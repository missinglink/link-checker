Resource = require 'model/Resource'
http = require 'http'

describe 'Resource', ->

  validUris = [
    'http://www.domain.com'
    'http://www.domain.com/test.php?hello=world'
    'http://www.domain.com'
    'http://www.domain.com:80'
    'https://www.domain.com:443'
    'http://12.32.34.254'
    'http://askubuntu.com/questions/12434534534/answers#comment12'
  ]

  invalidUrls = [
    'asdfsafsdfsdffds'
    'http:wwwsdf'
    '255.0.0.1'
    'http://%%%%%/sdfdgfsdfg'
  ]

  describe 'constructor', ->

    it 'should not accept invalid uri', ->
      ( -> new Resource()).should.throw 'Invalid uri'
      ( -> new Resource null).should.throw 'Invalid uri'
      ( -> new Resource undefined).should.throw 'Invalid uri'
      ( -> new Resource false).should.throw 'Invalid uri'
      ( -> new Resource []).should.throw 'Invalid uri'
      ( -> new Resource {}).should.throw 'Invalid uri'
      ( -> new Resource 1.111).should.throw 'Invalid uri'
      for url in invalidUrls
        ( -> new Resource url).should.throw 'Invalid uri'

    it 'should not accept invalid filters', ->
      uri = 'http://www.google.com/'
      ( -> new Resource uri, false ).should.throw 'Invalid filters'
      ( -> new Resource uri, {} ).should.throw 'Invalid filters'
      ( -> new Resource uri, 1.1 ).should.throw 'Invalid filters'
      ( -> new Resource uri, 'filters' ).should.throw 'Invalid filters'
      ( -> new Resource uri, -> ).should.throw 'Invalid filters'

      ( -> new Resource uri, [1, false]).should.throw 'filter is not a function'

    it 'should accept valid parameters', ->
      A = (uri) -> return uri
      B = (uri) -> return ''+uri
      for uri in validUris
        resource = new Resource uri, [A,B]
        resource.uri.should.equal uri
        resource.filters.should.eql [A,B]

    it 'should set empty array for filters if no filters are passed', ->
      uri = 'http://www.google.com/'
      ( -> new Resource uri, undefined).should.not.throw
      ( -> new Resource uri, null).should.not.throw
      ( -> new Resource uri ).should.not.throw

      resource = new Resource uri, null
      resource.filters.should.eql []

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
        resource.status_code.should.equal status

  describe 'setHTTPVersion', ->
    resource = new Resource validUris[0]
    it 'should set a valid version', ->
      resource.setHTTPVersion '1.1'
      resource.http_version.should.equal '1.1'

  describe 'setServer', ->
    resource = new Resource validUris[0]

    it 'should not accept an invalid server', ->
      ( -> resource.setServer()).should.throw 'Invalid server'
      ( -> resource.setServer(null)).should.throw 'Invalid server'
      ( -> resource.setServer(undefined)).should.throw 'Invalid server'
      ( -> resource.setServer(false)).should.throw 'Invalid server'
      ( -> resource.setServer([])).should.throw 'Invalid server'
      ( -> resource.setServer({})).should.throw 'Invalid server'
      ( -> resource.setServer(1.111)).should.throw 'Invalid server'
      ( -> resource.setServer(600)).should.throw 'Invalid server'      

    it 'should set a valid server', ->
      resource.setServer 'nginx'
      resource.server.should.equal 'nginx'

  describe 'setContentType', ->
    resource = new Resource validUris[0]

    it 'should not accept an invalid content type', ->
      ( -> resource.setContentType()).should.throw 'Invalid content type'
      ( -> resource.setContentType(null)).should.throw 'Invalid content type'
      ( -> resource.setContentType(undefined)).should.throw 'Invalid content type'
      ( -> resource.setContentType(false)).should.throw 'Invalid content type'
      ( -> resource.setContentType([])).should.throw 'Invalid content type'
      ( -> resource.setContentType({})).should.throw 'Invalid content type'
      ( -> resource.setContentType(1.111)).should.throw 'Invalid content type'
      ( -> resource.setContentType(600)).should.throw 'Invalid content type'      

    it 'should set a valid content type', ->
      resource.setContentType 'text/html'
      resource.content_type.should.equal 'text/html'

  describe 'setLastChecked', ->

    resource = new Resource validUris[0]

    it 'should not accept invalid parameters', ->
      ( -> resource.setLastChecked()).should.throw 'Invalid date'
      ( -> resource.setLastChecked(null)).should.throw 'Invalid date'
      ( -> resource.setLastChecked(undefined)).should.throw 'Invalid date'
      ( -> resource.setLastChecked(false)).should.throw 'Invalid date'
      ( -> resource.setLastChecked([])).should.throw 'Invalid date'
      ( -> resource.setLastChecked({})).should.throw 'Invalid date'
      ( -> resource.setLastChecked('status:OK')).should.throw 'Invalid date'
      ( -> resource.setLastChecked(1.111)).should.throw 'Invalid date'
      ( -> resource.setLastChecked(600)).should.throw 'Invalid date'

    it 'should accept valid paramenter', ->
      now = new Date()
      resource.setLastChecked(now).should.equal now
      resource.last_checked.should.equal now

  describe 'setRequestTime', ->
    resource = new Resource validUris[0]
    it 'should not accept invalid time', ->
      ( -> resource.setRequestTime()).should.throw 'Invalid time'
      ( -> resource.setRequestTime(null)).should.throw 'Invalid time'
      ( -> resource.setRequestTime(undefined)).should.throw 'Invalid time'
      ( -> resource.setRequestTime(false)).should.throw 'Invalid time'
      ( -> resource.setRequestTime([])).should.throw 'Invalid time'
      ( -> resource.setRequestTime({})).should.throw 'Invalid time'
      ( -> resource.setRequestTime('status:OK')).should.throw 'Invalid time'

    it 'should accept valid time', ->
      time = 256
      resource.setRequestTime(time).should.equal time
      resource.request_time.should.equal time

  describe 'isAbsolute()', ->
    absoluteUrls = [
      'http://www.domain.com/logo'
      'http://www.domain.com/test.php?hello=world'
      'https://www.domain.com/logo'
      'https://www.domain.com:80/logo'
      'https://www.domain.com:443/logo'
      'https://12.32.34.254/logo'
      'http://askubuntu.com/questions/12434534534/answers#comment12'
    ]

    relativeUrls = [
      '/logo.gif'
      '../index.php'
      '/src/img/./../logo.png'
    ]

    it 'should return true only for absoulte urls', ->
      for url in absoluteUrls
        Resource.isAbsolute(url).should.be.true

    it 'should return false for non-absoulte urls', ->
      Resource.isAbsolute().should.be.false
      Resource.isAbsolute(null).should.be.false
      Resource.isAbsolute(undefined).should.be.false
      Resource.isAbsolute(true).should.be.false
      Resource.isAbsolute(1.1).should.be.false
      Resource.isAbsolute([]).should.be.false
      Resource.isAbsolute({}).should.be.false

      for url in relativeUrls
        Resource.isAbsolute(url).should.be.false

  describe 'allowed()', ->
    it 'should not allow mailto links', ->
      Resource.allow('mailto:').should.be.false
    it 'should not allow ftp links', ->
      Resource.allow('ftp://www.google.com').should.be.false

    it 'should allow protocols http, https, ftp, //', ->
      Resource.allow('http://www.google.com').should.be.true
      Resource.allow('https://www.google.com').should.be.true
      Resource.allow('//ajax.google.com').should.be.true

  describe 'removeFragment()', ->
    it 'should add the original domain name to relative uri', ->

      uri1 = 'http://www.ex.com/index.php?postId=2#new-comment'
      uri2 = 'https://www.ex.com/#'

      Resource.removeFragment(uri1).should.equal 'http://www.ex.com/index.php?postId=2'
      Resource.removeFragment(uri2).should.equal 'https://www.ex.com/'

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

  describe 'addDefaultProtocol', ->
    it 'should add the default protocol when not present', ->
      Resource.addDefaultProtocol('www.google.com').should.equal Resource.defaultProtocol + '//www.google.com'
      Resource.addDefaultProtocol('//www.google.com').should.equal 'http://www.google.com'

    it 'should not modify the uri when the protocol is already present', ->
      Resource.addDefaultProtocol('https://www.google.com').should.equal 'https://www.google.com'

  describe 'lowerCase', ->

    it 'should transform protocol and hostname lowercase', ->
      Resource.lowerCase('HTTP://www.Google.com').should.equal 'http://www.google.com'
    
    it 'should not transform the query string in lowercase', ->
      Resource.lowerCase('HTTP://www.Google.com/a%C2%B1b').should.equal 'http://www.google.com/a%C2%B1b'

  describe 'removePort', ->

    it 'should remove the port from the uri', ->
      Resource.removePort('http://www.example.com:80/bar.html').should.equal 'http://www.example.com/bar.html'
    
    it 'should not alter the uri if the port is not present', ->
      Resource.removePort('http://www.example.com/bar.html').should.equal 'http://www.example.com/bar.html'

  describe 'useCanonicalSlashes', ->

    it 'should add a slash after a domain if not present', ->
      Resource.useCanonicalSlashes('http://www.example.com').should.equal 'http://www.example.com/'
    it 'should not add a slash after a domain if present', ->
      Resource.useCanonicalSlashes('http://www.example.com/').should.equal 'http://www.example.com/'
    it 'should not add a slash after a path if not present', ->
      Resource.useCanonicalSlashes('http://www.example.com/images').should.equal 'http://www.example.com/images' 
      Resource.useCanonicalSlashes('http://www.example.com/images/logo.jpg').should.equal 'http://www.example.com/images/logo.jpg'
    it 'should remove a slash after a path if present', ->
      Resource.useCanonicalSlashes('http://www.example.com/images/').should.equal 'http://www.example.com/images'
      Resource.useCanonicalSlashes('http://www.example.com/images/logo.jpg/').should.equal 'http://www.example.com/images/logo.jpg'