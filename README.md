## eventric MongoDB EventStore Adapter [![Build Status](https://travis-ci.org/efacilitation/eventric-store-mongodb.svg?branch=master)](https://travis-ci.org/efacilitation/eventric-store-mongodb)


## API


### initialize(options, callback)

`options{}` Object with options

* `host` The Host to which the MongoDb should connect (default: `127.0.0.1`)
* `port` The Port to which the MongoDb should connect (default: `27017`)
* `database` The name of the Database to which MongoDb should connect (default: `eventric`)
* `schema` The schema which we use to connect (default: `mongodb://`)
* `dbInstance` Already initialized mongo.Db (default: null), wont connect at all if provided


`callback(error)`

* `error` null or Error if one happened



### save(collectionName, document, callback)

`collectionName` Name of the collection where the given document gets stored into

`document` The object to be stored

`callback(error, docs)`

* `error` null or Error if one happened
* `docs` The stored document in an array


### find(collectionName, query, projection, callback)

`collectionName` Name of the collection where the find searches

`query` Query parameter, more documentation is [here](http://mongodb.github.io/node-mongodb-native/api-generated/collection.html#find)

`projection` Optional

`callback(error, docs)`

* `error` null or Error if one happened
* `docs` The documents found


### getProjectionStore(projectionName, callback)

callbacks with a mongodb collection which can be used for a projection

`projectionName` Name of the Projection for which a store should be returned

`callback(error, projectionStore)`

* `error` null or Error if one happened
* `projectionStore` MongoDb Collection


### getStoreName()

Returns the string `mongodb`




## Running Tests

**Attention** The specs will need a running MongoDB instance available at `mongodb://127.0.0.1:27017`. They create and remove a database named `__eventric_tests`.


Install dependencies

```
npm install
```

Execute specs and watcher

```
gulp
```
