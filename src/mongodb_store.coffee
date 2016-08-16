# TODO: Remove callback everywhere

MongoClient = require('mongodb').MongoClient

class MongoDBStore
  _optionDefaults:
    schema: 'mongodb://'
    host: '127.0.0.1'
    port: 27017
    database: 'eventric'
    dbInstance: null


  initialize: (@_context, options = {}) ->
    # TODO: Make db private but allow to request it to access the store directly if needed
    @db = null
    @_initializePromise = new Promise (resolve) =>
      @_defaults options, @_optionDefaults
      @_domainEventsCollectionName = "#{@_context.name}.DomainEvents"

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
    @_getNextDomainEventId()
    .then (domainEventId) =>
      # TODO: we should not modify input arguments in order to keep the code side effects free
      domainEvent.id = domainEventId
      @_getCollection @_domainEventsCollectionName
    .then (collection) ->
      collection.insert domainEvent
    .then (insertWriteOpResultObject) ->
      domainEvent = insertWriteOpResultObject.ops[0]
      return domainEvent


  _getNextDomainEventId: ->
    query =
      _id: 'domainEventSequence'
    document =
      $inc:
        currentDomainEventId: 1
    options =
      upsert: true
      new: true

    @_getCollection 'eventSourcingConfig'
    .then (collection) ->
      # TODO: findAndModify is deprecated: http://mongodb.github.io/node-mongodb-native/2.2/api/Collection.html#findAndModify
      # Use findOneAndUpdate: http://mongodb.github.io/node-mongodb-native/2.2/api/Collection.html#findOneAndUpdate
      collection.findAndModify query, null, document, options
    .then (findAndModifyWriteOpResultObject) ->
      return findAndModifyWriteOpResultObject.value.currentDomainEventId
    .catch (error) =>
      duplicateKeyError = 11000
      if error.code is duplicateKeyError
        return @_getNextDomainEventId()

      throw error


  findDomainEventsByName: (domainEventNames, callback) ->
    domainEventNames = [domainEventNames] if domainEventNames not instanceof Array
    query = 'name': $in: domainEventNames
    @_find query, callback


  findDomainEventsByAggregateId: (aggregateIds, callback) ->
    aggregateIds = [aggregateIds] if aggregateIds not instanceof Array
    query = 'aggregate.id': $in: aggregateIds
    @_find query, callback


  findDomainEventsByNameAndAggregateId: (domainEventNames, aggregateIds, callback) ->
    domainEventNames = [domainEventNames] if domainEventNames not instanceof Array
    aggregateIds = [aggregateIds] if aggregateIds not instanceof Array
    query =
      'name': $in: domainEventNames
      'aggregate.id': $in: aggregateIds
    @_find query, callback


  _find: (query, callback) ->
    @_getCollection @_domainEventsCollectionName
    .then (collection) ->
      collection.find(query).toArray()
    .then (results) ->
      callback null, results


  _getCollection: (collectionName) ->
    @_initializePromise
    .then =>
      new Promise (resolve, reject) =>
        @db.collection collectionName, (error, collection) ->
          if error
            return reject error
          resolve collection


  destroy: ->
    @_initializePromise
    .then =>
      @db.close()


module.exports = MongoDBStore
