MongoClient = require('mongodb').MongoClient

class MongoDBStore
  _optionDefaults:
    schema: 'mongodb://'
    host: '127.0.0.1'
    port: 27017
    database: 'eventric'


  initialize: (@_contextName, [options]..., callback=->) ->
    @_defaults (options ?= {}), @_optionDefaults
    @_domainEventsCollectionName = "#{@_contextName}.domain_events"
    @_projectionCollectionName   = "#{@_contextName}.projections"

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


  saveDomainEvent: (domainEvent, callback) ->
    @db.collection @_domainEventsCollectionName, (err, collection) =>
      return callback err, null if err

      collection.insert domainEvent, callback


  findAllDomainEvents: (callback) ->
    query = {}
    @_find query, callback


  findDomainEventsByName: (name, callback) ->
    query = 'name': name
    @_find query, callback


  findDomainEventsByAggregateId: (aggregateId, callback) ->
    query = 'aggregate.id': aggregateId
    @_find query, callback


  findDomainEventsByAggregateName: (aggregateName, callback) ->
    query = 'aggregate.name': aggregateName
    @_find query, callback


  _find: (query, callback) ->
    @db.collection @_domainEventsCollectionName, (err, collection) =>
      collection.find query, (err, cursor) =>
        return callback err, null if err
        cursor.toArray callback


  getProjectionStore: (projectionName, callback) ->
    @db.collection "#{@_projectionCollectionName}.#{projectionName}", callback


  clearProjectionStore: (projectionName, callback) ->
    @db.dropCollection "#{@_projectionCollectionName}.#{projectionName}", (err, result) ->
      callback null, result


module.exports = new MongoDBStore