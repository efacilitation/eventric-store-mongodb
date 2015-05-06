## eventric MongoDB Store Adapter [![Build Status](https://travis-ci.org/efacilitation/eventric-store-mongodb.svg?branch=master)](https://travis-ci.org/efacilitation/eventric-store-mongodb)


## API


### initialize(contextName, options, callback)

`contextName` String Name of the context for which the store is responsible

`options{}` Object with options

* `host` The Host to which the MongoDb should connect (default: `127.0.0.1`)
* `port` The Port to which the MongoDb should connect (default: `27017`)
* `database` The name of the Database to which MongoDb should connect (default: `eventric`)
* `schema` The schema which we use to connect (default: `mongodb://`)
* `dbInstance` Already initialized mongo.Db (default: null), wont connect at all if provided


`callback(error)`

* `error` null or Error if one happened


### saveDomainEvent(domainEvent, callback)

`domainEvent` The DomainEvent to be stored

`callback(error, domainEvents)`

* `error` null or Error if one happened
* `domainEvents` The stored domainEvents in an array


### findDomainEventsByName(domainEventName, callback)

Finds DomainEvents with the given Name in Store

`domainEventName` String|Array Name, or array of names, of the DomainEvent

`callback(error, domainEvents)`

* `error` null or Error if one happened
* `domainEvents` The domainEvents found


### findDomainEventsByAggregateId(aggregateId, callback)

Finds DomainEvents with the given AggregateId in Store

`aggregateId` String|Array Id, or array of ids, of the Aggregate

`callback(error, domainEvents)`

* `error` null or Error if one happened
* `domainEvents` The domainEvents found


### findDomainEventsByNameAndAggregateId(domainEventName, aggregateId, callback)

Finds DomainEvents with the given AggregateName in the Store

`domainEventName` String|Array Name, or array of names, of the DomainEvent

`aggregateId` String|Array Id, or array of ids, of the Aggregate

`callback(error, domainEvents)`

* `error` null or Error if one happened
* `domainEvents` The domainEvents found



### getProjectionStore(projectionName, callback)

callbacks with a mongodb collection which can be used for a projection

`projectionName` Name of the Projection for which a projectionStore should be returned

`callback(error, projectionStore)`

* `error` null or Error if one happened
* `projectionStore` MongoDb Collection Projection Store


### clearProjectionStore(projectionName, callback) ->

clears the projectionStore with the given name

`projectionName` Name of the Projection which should be cleared

`callback(error, result)`

* `error` null or Error if one happened
* `result` Result of the dropCollection call




## Running Tests

**Attention** The specs will need a running MongoDB instance available at `mongodb://127.0.0.1:27017`. They create and remove a database named `__eventric_tests`.


Install dependencies

```
npm install
```

Execute specs and watcher

```
gulp watch
```
