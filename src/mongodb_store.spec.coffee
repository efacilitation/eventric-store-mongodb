require('es6-promise').polyfill()
global.chai = require 'chai'
global.expect = chai.expect
global.sinon = require 'sinon'
global.sandbox = sinon.sandbox.create()
global.sinonChai = require 'sinon-chai'
chai.use sinonChai

eventricStoreSpecs = require 'eventric-store-specs'

MongoClient = require('mongodb').MongoClient
autoIncrement = require 'mongodb-autoincrement'

MongoDbStore = require './mongodb_store'


describe 'Integration', ->
  store = null

  beforeEach ->
    contextFake =
      name: 'contextFake'
    store = new MongoDbStore()
    store.initialize contextFake
    .then ->
      store.db.dropDatabase()

  eventricStoreSpecs.runFor
    StoreClass: MongoDbStore


describe 'MongoDB store', ->
  contextFake = null
  store = null

  beforeEach ->
    contextFake =
      name: 'contextFake'
    store = new MongoDbStore()


  afterEach ->
    sandbox.restore()


  describe '#initialize', ->

    beforeEach ->
      sandbox.stub(MongoClient, 'connect').returns Promise.resolve()


    it 'should not call MongoClient.connect given a dbInstance in the options', ->
      options =
        dbInstance: {}
      store.initialize contextFake, options
      .then ->
        expect(MongoClient.connect).to.not.have.been.called


    it 'should call MongoClient.connect with the correct options given no dbInstance in the options', ->
      options =
        database: 'eventric_store_mongodb_specs'
      store.initialize contextFake, options
      .then ->
        expect(MongoClient.connect).to.have.been.calledWith 'mongodb://127.0.0.1:27017/eventric_store_mongodb_specs'


  describe '#saveDomainEvent', ->

    beforeEach ->
      store.initialize contextFake


    it 'should reject with an error given autoincrement callbacks with an error', ->
      errorFake = new Error 'errorFake'
      sandbox.stub(autoIncrement, 'getNextSequence').yields errorFake
      store.saveDomainEvent {}
      .catch (error) ->
        expect(error).to.equal errorFake


    it 'should reject with an error given the database rejects with an error', ->
      errorFake = new Error 'errorFake'
      collection = insert: -> Promise.reject errorFake
      sandbox.stub(store, '_getCollection').returns Promise.resolve collection
      store.saveDomainEvent {}
      .catch (error) ->
        expect(error).to.equal errorFake
