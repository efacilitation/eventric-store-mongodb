MongoClient = require('mongodb').MongoClient

class MongoDBStore
  _optionDefaults:
    schema: 'mongodb://'
    host: '127.0.0.1'
    port: 27017
    database: 'eventric'


  initialize: ([options]..., callback=->) ->
    @_defaults (options ?= {}), @_optionDefaults

    if options.dbInstance
      @db = options.dbInstance
      callback null
      return

    connectUri = "#{options.schema}#{options.host}:#{options.port}/#{options.database}"
    MongoClient.connect connectUri, (err, db) =>
      return callback err, null if err

      @db = db
      callback null


  _defaults: (options, optionDefaults) ->
    allKeys = [].concat (Object.keys options), (Object.keys optionDefaults)
    for key in allKeys when !options[key] and optionDefaults[key]
      options[key] = optionDefaults[key]


  save: (collectionName, doc, callback) ->
    @collection collectionName, (err, collection) =>
      return callback err, null if err

      collection.insert doc, callback


  find: ([collectionName, query, projection]..., callback) ->
    if not query
      err = new Error 'Missing query'
      callback err, null
      return
    projection = {} unless projection

    @collection collectionName, (err, collection) =>
      collection.find query, projection, (err, cursor) =>
        return callback err, null if err

        cursor.toArray callback


  collection: (collectionName, callback) ->
    @db.collection collectionName, callback


module.exports = new MongoDBStore