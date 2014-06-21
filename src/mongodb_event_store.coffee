MongoClient = require('mongodb').MongoClient

class MongoDBEventStore
  initialize: ([_db]..., callback) ->
    if _db
      @db = _db
      callback? null
      return

    MongoClient.connect 'mongodb://127.0.0.1:27017/events', (err, db) =>
      if err
        callback? err, null
        return

      @db = db
      callback? null


  save: (domainEvent, callback) ->
    @db.collection domainEvent.context, (err, collection) ->
      return callback err, null if err

      collection.insert domainEvent, (err, doc) ->
        return callback err if err

        callback null


  find: ([contextName, query, projection]..., callback) ->
    if not query
      err = new Error 'Missing query'
      callback err, null
      return
    projection = {} unless projection

    @db.collection contextName, (err, collection) =>
      return callback err, null if err

      collection.find query, projection, (err, cursor) =>
        return callback err, null if err

        cursor.toArray (err, items) =>
          return callback err, null if err

          callback null, items


module.exports = new MongoDBEventStore