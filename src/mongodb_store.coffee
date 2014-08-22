MongoClient = require('mongodb').MongoClient

class MongoDBStore
  _optionDefaults:
    schema: 'mongodb://'
    host: '127.0.0.1'
    port: 27017
    database: 'eventric'


  initialize: (@_contextName, [options]..., callback=->) ->
    @_defaults (options ?= {}), @_optionDefaults
    @_domainEventsCollectionName = "#{@_contextName}.DomainEvents"
    @_projectionCollectionName   = "#{@_contextName}.Projection"

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


  findDomainEventsByName: (names, callback) ->
    names = [names] if names not instanceof Array
    query = 'name': $in: names
    @_find query, callback


  findDomainEventsByAggregateId: (aggregateIds, callback) ->
    aggregateIds = [aggregateIds] if aggregateIds not instanceof Array
    query = 'aggregate.id': $in: aggregateIds
    @_find query, callback


  findDomainEventsByAggregateName: (aggregateNames, callback) ->
    aggregateNames = [aggregateNames] if aggregateNames not instanceof Array
    query = 'aggregate.name': $in: aggregateNames
    @_find query, callback


  findDomainEventsByNameAndAggregateId: (names, aggregateIds, callback) ->
    names = [names] if names not instanceof Array
    aggregateIds = [aggregateIds] if aggregateIds not instanceof Array
    query =
      'name': $in: names
      'aggregate.id': $in: aggregateIds
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


module.exports = MongoDBStore