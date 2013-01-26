MongoGateway = require 'lib/MongoGateway'
ObjectID = require('mongodb').ObjectID

hexId = '50be30ad819e6b8d6e000001'
validObjectID = new ObjectID hexId

describe 'MongoGateway', ->


  describe 'convertId', ->  
    
    query = {}

    it 'should convert id into _id', ->

      query.id = 'some_random_id'
      newQuery = MongoGateway.convertId query
      newQuery.should.have.property '_id'
      newQuery.should.not.have.property 'id'
      newQuery._id.should.equal 'some_random_id'

  describe 'useObjectId', ->

    query = {}

    it 'should not cast an ObjectID', ->

      query._id = validObjectID
      (-> MongoGateway.useObjectID query).should.not.throw()
      newQuery = MongoGateway.useObjectID query
      newQuery.should.have.property '_id'
      newQuery._id.should.be.instanceof ObjectID

    it 'should cast an hex id to ObjectID', ->

      query._id = hexId
      (-> MongoGateway.useObjectID query).should.not.throw()
      newQuery = MongoGateway.useObjectID query
      newQuery.should.have.property '_id'
      newQuery._id.should.be.instanceof ObjectID
      newQuery._id.toString().should.equal hexId

  describe 'removeIdFromUpdate', ->

    it 'should remove an id if present', ->

      update =
        '$set':
          _id: 'an id'
          foo: 'bar'

      afterUpdate = MongoGateway.removeIdFromUpdate update
      afterUpdate.should.eql { '$set': { 'foo': 'bar' } }

    it 'should do nothing if an id is not present', ->

      update =
        '$set':
          foo: 'bar'

      afterUpdate = MongoGateway.removeIdFromUpdate update

      afterUpdate.should.eql { '$set': { 'foo': 'bar' } }