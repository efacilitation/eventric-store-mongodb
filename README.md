## eventric MongoDB EventStore Adapter [![Build Status](https://travis-ci.org/efacilitation/eventric-store-mongodb.svg?branch=master)](https://travis-ci.org/efacilitation/eventric-store-mongodb)


## API


### save(collectionName, document, callback)

`collectionName` Name of the collection where the given document gets stored into

`document` The object to be stored

`callback` Optional callback parameter with first argument an error if one happened and as second parameter the stored document in an array



### find(collectionName, query, projection, callback)

`collectionName` Name of the collection where the find searches

`query` Query parameter, more documentation is [here](http://mongodb.github.io/node-mongodb-native/api-generated/collection.html#find)

`projection` Optional

`callback` Callback with first argument an error if one happened and as second parameter the found documents



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