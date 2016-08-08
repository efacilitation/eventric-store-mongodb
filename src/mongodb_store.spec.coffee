require('es6-promise').polyfill()
global.chai      = require 'chai'
global.expect    = chai.expect
global.sinon     = require 'sinon'
global.sandbox   = sinon.sandbox.create()
global.sinonChai = require 'sinon-chai'
chai.use sinonChai

eventricStoreSpecs = require 'eventric-store-specs'

mongodb = require 'mongodb'
MongoClient = mongodb.MongoClient
autoIncrement = require 'mongodb-autoincrement'

MongoDbStore = require './mongodb_store'


describe 'MongoDB Store', ->
  databases = []

  beforeEach ->
    usedDatabaseNames = [
      'eventric'
      'eventric_store_mongodb_specs'
    ]
    Promise.all usedDatabaseNames.map (usedDatabaseName) ->
      MongoClient.connect "mongodb://127.0.0.1:27017/#{usedDatabaseName}"
      .then (db) ->
        databases.push db
        db.dropDatabase()


  after ->
    for database in databases
      database.close()


  eventricStoreSpecs.runFor
    StoreClass: MongoDbStore

    initializeCallback: (store) ->
      options =
        dbInstance: sandbox.stub()
      store.initialize name: 'FakeContext'


  describe 'Custom', ->

    store = null

    beforeEach ->
      sandbox.restore()
      store = new MongoDbStore()
      sandbox.spy MongoClient, 'connect'


    describe '#initialize', ->

      it 'should not call MongoClient.connect given a dbInstance in the options', ->
        options =
          dbInstance: sandbox.stub()
        store.initialize name: 'exampleContext', options
        .then ->
          expect(MongoClient.connect).to.not.have.been.called


      it 'should call MongoClient.connect with the correct options given no dbInstance in the options', ->
        options =
          database: 'eventric_store_mongodb_specs'
        store.initialize name: 'exampleContext', options
        .then ->
          expect(MongoClient.connect).to.have.been.calledWith 'mongodb://127.0.0.1:27017/eventric_store_mongodb_specs'


    describe '#saveDomainEvent', ->

      beforeEach ->
        options =
          database: 'eventric_store_mongodb_specs'
        store.initialize name: 'exampleContext', options


      it 'should reject with an error given autoincrement callbacks with an error', ->
        dummyError = new Error 'dummy'
        sandbox.stub(autoIncrement, 'getNextSequence').yields dummyError
        store.saveDomainEvent {}
        .catch (error) ->
          expect(error).to.equal dummyError


      it 'should reject with an error given the database rejects with an error', ->
        dummyError = new Error 'dummy'
        collection = insert: -> Promise.reject dummyError
        sandbox.stub(store, '_getCollection').returns Promise.resolve collection
        store.saveDomainEvent {}
        .catch (error) ->
          expect(error).to.equal dummyError
