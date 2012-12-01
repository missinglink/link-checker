# assert = require 'assert'
should       = require 'should'
ClassChecker = require 'lib/utils/classChecker'

describe 'Class checker', ->

  describe 'constructor', ->

    it 'should return the right class type', ->

      ClassChecker([]).should.equal 'array'
      ClassChecker(new Array).should.equal 'array'

      ClassChecker(true).should.equal 'boolean'
      ClassChecker(new Boolean true).should.equal 'boolean'

      ClassChecker(1).should.equal 'number'
      ClassChecker(1.1234).should.equal 'number'
      ClassChecker(-1.1234).should.equal 'number'
      ClassChecker(0x1234567).should.equal 'number'
      ClassChecker(Infinity).should.equal 'number'
      ClassChecker(new Number 10).should.equal 'number'

      ClassChecker('some string').should.equal 'string'
      ClassChecker(new String 'some string').should.equal 'string'

      ClassChecker( () -> ).should.equal 'function'
      ClassChecker( () -> return {} ).should.equal 'function'
      ClassChecker(new Function ).should.equal 'function'
      
      ClassChecker(new Date ).should.equal 'date'

      ClassChecker(/fabrizio/).should.equal 'regexp'
      ClassChecker(new RegExp 'fabrizio').should.equal 'regexp'
