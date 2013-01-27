ResourceFilter = require 'filters/ResourceFilter'

Resource = require 'model/Resource'

describe 'ResourceFilter', ->

  describe 'filter', ->
    
    href = 'index.php'
    originDomain = 'http://www.google.com/'
    
    it 'should not accept invalid href', ->
      (-> ResourceFilter.filter()).should.throw 'Invalid href'
      (-> ResourceFilter.filter undefined).should.throw 'Invalid href'
      (-> ResourceFilter.filter null).should.throw 'Invalid href'
      (-> ResourceFilter.filter 1.1).should.throw 'Invalid href'
      (-> ResourceFilter.filter false).should.throw 'Invalid href'
      (-> ResourceFilter.filter []).should.throw 'Invalid href'
      (-> ResourceFilter.filter {}).should.throw 'Invalid href'

    it 'should not accept invalid originDomain', ->
      (-> ResourceFilter.filter href).should.throw 'Invalid originDomain'
      (-> ResourceFilter.filter href, undefined).should.throw 'Invalid originDomain'
      (-> ResourceFilter.filter href, null).should.throw 'Invalid originDomain'
      (-> ResourceFilter.filter href, 1.1).should.throw 'Invalid originDomain'
      (-> ResourceFilter.filter href, false).should.throw 'Invalid originDomain'
      (-> ResourceFilter.filter href, []).should.throw 'Invalid originDomain'
      (-> ResourceFilter.filter href, {}).should.throw 'Invalid originDomain'

      (-> ResourceFilter.filter href, 'somedomain').should.throw 'Invalid originDomain'

    it 'should accept valid parameters', ->
      (-> ResourceFilter.filter href, originDomain).should.not.throw()


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
      conv = ResourceFilter.getAbsoluteURI
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

  describe 'removeFragment()', ->
    it 'should add the original domain name to relative uri', ->

      uri1 = 'http://www.ex.com/index.php?postId=2#new-comment'
      uri2 = 'https://www.ex.com/#'

      ResourceFilter.removeFragment(uri1).should.equal 'http://www.ex.com/index.php?postId=2'
      ResourceFilter.removeFragment(uri2).should.equal 'https://www.ex.com/'

  describe 'addDefaultProtocol', ->
    it 'should add the default protocol when not present', ->
      ResourceFilter.addDefaultProtocol('www.google.com').should.equal Resource.defaultProtocol + '//www.google.com'
      ResourceFilter.addDefaultProtocol('//www.google.com').should.equal 'http://www.google.com'

    it 'should not modify the uri when the protocol is already present', ->
      ResourceFilter.addDefaultProtocol('https://www.google.com').should.equal 'https://www.google.com'

  describe 'lowerCase', ->

    it 'should transform protocol and hostname lowercase', ->
      ResourceFilter.lowerCase('HTTP://www.Google.com').should.equal 'http://www.google.com'
    
    it 'should not transform the query string in lowercase', ->
      ResourceFilter.lowerCase('HTTP://www.Google.com/a%C2%B1b').should.equal 'http://www.google.com/a%C2%B1b'

  describe 'removePort', ->

    it 'should remove the port from the uri', ->
      ResourceFilter.removePort('http://www.example.com:80/bar.html').should.equal 'http://www.example.com/bar.html'
    
    it 'should not alter the uri if the port is not present', ->
      ResourceFilter.removePort('http://www.example.com/bar.html').should.equal 'http://www.example.com/bar.html'

  describe 'useCanonicalSlashes', ->

    it 'should add a slash after a domain if not present', ->
      ResourceFilter.useCanonicalSlashes('http://www.example.com').should.equal 'http://www.example.com/'
    it 'should not add a slash after a domain if present', ->
      ResourceFilter.useCanonicalSlashes('http://www.example.com/').should.equal 'http://www.example.com/'
    it 'should not add a slash after a path if not present', ->
      ResourceFilter.useCanonicalSlashes('http://www.example.com/images').should.equal 'http://www.example.com/images' 
      ResourceFilter.useCanonicalSlashes('http://www.example.com/images/logo.jpg').should.equal 'http://www.example.com/images/logo.jpg'
    it 'should remove a slash after a path if present', ->
      ResourceFilter.useCanonicalSlashes('http://www.example.com/images/').should.equal 'http://www.example.com/images'
      ResourceFilter.useCanonicalSlashes('http://www.example.com/images/logo.jpg/').should.equal 'http://www.example.com/images/logo.jpg'