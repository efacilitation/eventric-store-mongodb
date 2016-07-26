MongoClient = require('mongodb').MongoClient

class MongoDBStore
  _optionDefaults:
    schema: 'mongodb://'
    host: '127.0.0.1'
    port: 27017
    database: 'eventric'


  initialize: (@_context, [options]...) ->
    new Promise (resolve) =>
      @_defaults (options ?= {}), @_optionDefaults
      @_domainEventsCollectionName = "#{@_context.name}.DomainEvents"
      @_projectionCollectionName   = "#{@_context.name}.Projection"

      if options.dbInstance
        @db = options.dbInstance
        return resolve()

      connectUri = "#{options.schema}#{options.host}:#{options.port}/#{options.database}"
      MongoClient.connect connectUri
      .then (db) =>
        @db = db
        resolve()


  _defaults: (options, optionDefaults) ->
    allKeys = [].concat (Object.keys options), (Object.keys optionDefaults)
    for key in allKeys when !options[key] and optionDefaults[key]
      options[key] = optionDefaults[key]


  saveDomainEvent: (domainEvent) ->
    @_getCollection @_domainEventsCollectionName
    .then (collection) ->
      collection.insert domainEvent


  # TODO: remove this callback mess everywhere
  findDomainEventsByName: (names, callback) ->
    names = [names] if names not instanceof Array
    query = 'name': $in: names
    @_find query, callback


  findDomainEventsByAggregateId: (aggregateIds, callback) ->
    aggregateIds = [aggregateIds] if aggregateIds not instanceof Array
    query = 'aggregate.id': $in: aggregateIds
    @_find query, callback


  findDomainEventsByNameAndAggregateId: (names, aggregateIds, callback) ->
    names = [names] if names not instanceof Array
    aggregateIds = [aggregateIds] if aggregateIds not instanceof Array
    query =
      'name': $in: names
      'aggregate.id': $in: aggregateIds
    @_find query, callback


  _find: (query, callback) ->
    @_getCollection @_domainEventsCollectionName
    .then (collection) ->
      collection.find(query).toArray()
      .then (results) ->
        callback null, results


  _getCollection: (collectionName) ->
    new Promise (resolve, reject) =>
      @db.collection collectionName, (error, collection) ->
        if error
          return reject error
        resolve collection


  getProjectionStore: (projectionName) ->
    @_getCollection "#{@_projectionCollectionName}.#{projectionName}"


  clearProjectionStore: (projectionName) ->
    new Promise (resolve, reject) =>
      @db.dropCollection "#{@_projectionCollectionName}.#{projectionName}", (error, result) ->
        if error and error.message isnt 'ns not found'
          return reject error
        resolve result


module.exports = MongoDBStore
