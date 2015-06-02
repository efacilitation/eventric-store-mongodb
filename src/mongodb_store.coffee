MongoClient = require('mongodb').MongoClient

class MongoDBStore
  _optionDefaults:
    schema: 'mongodb://'
    host: '127.0.0.1'
    port: 27017
    database: 'eventric'


  initialize: (@_context, [options]...) ->  new Promise (resolve, reject) =>
    @_defaults (options ?= {}), @_optionDefaults
    @_domainEventsCollectionName = "#{@_context.name}.DomainEvents"
    @_projectionCollectionName   = "#{@_context.name}.Projection"

    if options.dbInstance
      @db = options.dbInstance
      return resolve()

    connectUri = "#{options.schema}#{options.host}:#{options.port}/#{options.database}"
    MongoClient.connect connectUri, (err, db) =>
      if err
        return reject err

      @db = db
      resolve()


  _defaults: (options, optionDefaults) ->
    allKeys = [].concat (Object.keys options), (Object.keys optionDefaults)
    for key in allKeys when !options[key] and optionDefaults[key]
      options[key] = optionDefaults[key]


  saveDomainEvent: (domainEvent) ->  new Promise (resolve, reject) =>
    @db.collection @_domainEventsCollectionName, (err, collection) ->
      if err
        return reject err

      collection.insert domainEvent, (err, result) ->
        if err
          return reject err
        resolve result


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
    @db.collection @_domainEventsCollectionName, (err, collection) ->
      collection.find query, (err, cursor) ->
        return callback err, null if err
        cursor.toArray callback


  getProjectionStore: (projectionName) ->  new Promise (resolve, reject) =>
    @db.collection "#{@_projectionCollectionName}.#{projectionName}", (err, collection) ->
      if err
        return reject err

      resolve collection


  clearProjectionStore: (projectionName) ->  new Promise (resolve, reject) =>
    @db.dropCollection "#{@_projectionCollectionName}.#{projectionName}", (err, result) ->
      if err and err.message isnt 'ns not found'
        return reject err
      resolve result


module.exports = MongoDBStore
