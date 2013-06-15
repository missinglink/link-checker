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

    it 'should accept valid parameters', ->
      for uri in validUris
        (-> new Resource uri).should.not.throw()
        resource = new Resource uri
        resource.uri.should.equal uri

# ---------------------------------------------------------------------

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

# ---------------------------------------------------------------------

  describe 'setHTTPVersion', ->
    resource = new Resource validUris[0]
    it 'should set a valid version', ->
      resource.setHTTPVersion '1.1'
      resource.http_version.should.equal '1.1'

# ---------------------------------------------------------------------

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

# ---------------------------------------------------------------------

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

# ---------------------------------------------------------------------

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

# ---------------------------------------------------------------------

  describe 'setRequestTime', ->

    describe 'failures', ->

      call() for call in [null, undefined, false, '', NaN, -1, [], {}, new Date, new Object, () ->].map (invalid) ->
        () ->
          it "should not accept #{invalid} as request time", ->
            (-> (new Resource validUris[0]).setRequestTime invalid).should.throw 'Invalid time'

    describe 'success', ->

      call() for call in [0, 1, 10000].map (valid) ->
        () ->
          it "should accept #{valid} as request time", ->      
            (new Resource validUris[0]).setRequestTime(valid).should.equal valid

# ---------------------------------------------------------------------

  describe 'isAbsolute()', ->
    absoluteUrls = [
      'http://www.domain.com/logo'
      'http://www.domain.com/test.php?hello=world'
      'https://www.domain.com/logo'
      'https://www.domain.com:80/logo'
      'https://www.domain.com:443/logo'
      'https://12.32.34.254/logo'
      'http://askubuntu.com/questions/12434534534/answers#comment12'
      'http://www.google.com'
      'mailto:fab@gmail.com'
    ]

    relativeUrls = [
      '/logo.gif'
      '../index.php'
      '/src/img/./../logo.png'
      '#'
      './'
      'css/style.css'
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

# ---------------------------------------------------------------------

  describe 'isProtocolAllowed', ->
    it 'should not allow mailto links', ->
      Resource.isProtocolAllowed('mailto:').should.be.false
    it 'should not allow ftp links', ->
      Resource.isProtocolAllowed('ftp://www.google.com').should.be.false

    it 'should allow protocols http, https, //', ->
      Resource.isProtocolAllowed('http://www.google.com').should.be.true
      Resource.isProtocolAllowed('https://www.google.com').should.be.true
      Resource.isProtocolAllowed('//ajax.google.com').should.be.true
      Resource.isProtocolAllowed('/').should.be.true
      Resource.isProtocolAllowed('./css/style.css').should.be.true
      Resource.isProtocolAllowed('css/style.css').should.be.true
      Resource.isProtocolAllowed('#').should.be.true
