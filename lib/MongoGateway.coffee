Db       = require('mongodb').Db
Server   = require('mongodb').Server
ObjectID = require('mongodb').ObjectID

class MongoGateway

  @db = undefined

  @init: (configDb) ->
    MongoGateway.getDbInstance configDb.host, configDb.dbName, configDb.port

  @setLogger: (@logger) ->

  @getLogger: () ->
    return MongoGateway.logger

  # Options
  #   safe {true | {w:n, wtimeout:n} | {fsync:true}, default:false}, execute insert with a getLastError command returning the result of the insert command.
  #   readPreference {String}, the prefered read preference (ReadPreference.PRIMARY, ReadPreference.PRIMARY_PREFERRED, ReadPreference.SECONDARY, ReadPreference.SECONDARY_PREFERRED, ReadPreference.NEAREST).
  #   native_parser {Boolean, default:false}, use c++ bson parser.
  #   forceServerObjectId {Boolean, default:false}, force server to create _id fields instead of client.
  #   pkFactory {Object}, object overriding the basic ObjectID primary key generation.
  #   serializeFunctions {Boolean, default:false}, serialize functions.
  #   raw {Boolean, default:false}, peform operations using raw bson buffers.
  #   recordQueryStats {Boolean, default:false}, record query statistics during execution.
  #   reaper {Boolean, default:false}, enables the reaper, timing out calls that never return.
  #   reaperInterval {Number, default:10000}, number of miliseconds between reaper wakups.
  #   reaperTimeout {Number, default:30000}, the amount of time before a callback times out.
  #   retryMiliSeconds {Number, default:5000}, number of miliseconds between retries.
  #   numberOfRetries {Number, default:5}, number of retries off connection.

  @getDbInstance: (host, dbName, port, options = {safe:true}) ->
    if MongoGateway.db is undefined
      options.logger = MongoGateway.getLogger()
      dbServer = new Server host, port
      MongoGateway.db = new Db dbName, dbServer, options
    return MongoGateway.db

  @connect: (username, password) ->

    # open() calls server.connect() internally
    MongoGateway.getDbInstance().open (err, Db) ->
      if err? then throw new Error "error #{err} when opening a connection", 500

      if username? and password?
        Db.authenticate username, password, (err, result) ->
          if err? or result is false or result is null
            throw new Error "error #{err} authenticating with: #{username}:#{password}", 500

  # Options
  #   safe {true | {w:n, wtimeout:n} | {fsync:true}, default:false}, executes with a getLastError command returning the results of the command on MongoDB.
  #   continueOnError/keepGoing {Boolean, default:false}, keep inserting documents even if one document has an error, mongodb 1.9.1 >.
  #   serializeFunctions {Boolean, default:false}, serialize functions on the document.

  @insert: (targetCollection, data, callback) ->
    if callback? then options = safe: true
    collection = MongoGateway.db.collection targetCollection
    
    # MongoGateway._authenticate () ->
    collection.insert data, options, callback

  @findOne: (targetCollection, query, callback) ->

    collection = MongoGateway.db.collection targetCollection

    for k, v of query
      query._id = new ObjectID(v)  if k is '_id'
    collection.findOne query, callback

  # Options
  # limit {Number, default:0}, sets the limit of documents returned in the query.
  # sort {Array | Object}, set to sort the documents coming back from the query. Array of indexes, [[‘a’, 1]] etc.
  # fields {Object}, the fields to return in the query. Object of fields to include or exclude (not both), {‘a’:1}
  # skip {Number, default:0}, set to skip N documents ahead in your query (useful for pagination).
  # hint {Object}, tell the query to use specific indexes in the query. Object of indexes to use, {‘_id’:1}
  # explain {Boolean, default:false}, explain the query instead of returning the data.
  # snapshot {Boolean, default:false}, snapshot query.
  # timeout {Boolean, default:false}, specify if the cursor can timeout.
  # tailable {Boolean, default:false}, specify if the cursor is tailable.
  # tailableRetryInterval {Number, default:100}, specify the miliseconds between getMores on tailable cursor.
  # numberOfRetries {Number, default:5}, specify the number of times to retry the tailable cursor.
  # awaitdata {Boolean, default:false} allow the cursor to wait for data, only applicable for tailable cursor.
  # exhaust {Boolean, default:false} have the server send all the documents at once as getMore packets, not recommended.
  # batchSize {Number, default:0}, set the batchSize for the getMoreCommand when iterating over the query results.
  # returnKey {Boolean, default:false}, only return the index key.
  # maxScan {Number}, Limit the number of items to scan.
  # min {Number}, Set index bounds.
  # max {Number}, Set index bounds.
  # showDiskLoc {Boolean, default:false}, Show disk location of results.
  # comment {String}, You can put a $comment field on a query to make looking in the profiler logs simpler.
  # raw {Boolean, default:false}, Return all BSON documents as Raw Buffer documents.
  # readPreference {String}, the preferred read preference ((Server.PRIMARY, Server.PRIMARY_PREFERRED, Server.SECONDARY, Server.SECONDARY_PREFERRED, Server.NEAREST).
  # numberOfRetries {Number, default:5}, if using awaidata specifies the number of times to retry on timeout.
  # partial {Boolean, default:false}, specify if the cursor should return partial results when querying against a sharded system
  @find: (targetCollection, query, fields, options, callback) ->
    collection = MongoGateway.db.collection targetCollection

    cursor = collection.find query, fields, options
    callback null, cursor

  # @param targetCollection string the name of the collection to update
  # @param whereQuery Object 
  # @param updateQuery Object
  # @param options Object multi, upsert, safe
  # @param callback function
  @update: (targetCollection, whereQuery, updateQuery, options, callback) ->
    collection = MongoGateway.db.collection targetCollection

    safe = options.safe || false
    multi = options.multi || false
    upsert = options.upsert || false
    updateOptions = {safe:safe, multi:multi, upsert:upsert}
    collection.update whereQuery, updateQuery, updateOptions, callback

  @remove: (targetCollection, docId, callback) ->
    collection = MongoGateway.db.collection targetCollection
    
    collection.remove {_id: new ObjectID(docId)}, {safe: 1}, callback

module.exports = MongoGateway