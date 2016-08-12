require('es6-promise').polyfill()
global.chai = require 'chai'
global.expect = chai.expect
global.sinon = require 'sinon'
global.sandbox = sinon.sandbox.create()
global.sinonChai = require 'sinon-chai'
chai.use sinonChai

eventricStoreSpecs = require 'eventric-store-specs'

MongoClient = require('mongodb').MongoClient

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
      # TODO: Use store.destroy() if available
      store.db.close()


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
    # TODO: Use store.destroy() if available
    store.db?.close?()
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


    it 'should reject with an error given an error occurs by getting the next domain event id', ->
      errorFake = new Error 'errorFake'
      eventSourcingConfigCollectionFake =
        findAndModify: sandbox.stub().returns Promise.reject errorFake

      collectionStub = sandbox.stub store.db, 'collection'
      collectionStub.withArgs('eventSourcingConfig', sandbox.match.func).yields null, eventSourcingConfigCollectionFake

      store.saveDomainEvent {}
      .catch (error) ->
        expect(error).to.equal errorFake


    it 'should retry getting the next domain event id given an duplicate key error occurs by getting the next domain event id', ->
      findAndModifyStub = sandbox.stub()

      errorFake = new Error 'errorFake'
      errorFake.code = 11000
      findAndModifyStub.onCall(0).returns Promise.reject errorFake

      eventSourcingConfigResultFake =
        value:
          currentDomainEventId: 1
      findAndModifyStub.onCall(1).returns Promise.resolve eventSourcingConfigResultFake

      eventSourcingConfigCollectionFake =
        findAndModify: findAndModifyStub

      collectionStub = sandbox.stub store.db, 'collection'
      collectionStub.withArgs('eventSourcingConfig', sandbox.match.func).yields null, eventSourcingConfigCollectionFake

      fakeDomainEvent =
        name: 'EventName'
      insertWriteOpResultObjectFake =
        ops: [
          name: 'EventName'
        ]
      domainEventsCollectionFake =
        insert: sandbox.stub().returns Promise.resolve insertWriteOpResultObjectFake
      collectionStub.withArgs("#{contextFake.name}.DomainEvents", sandbox.match.func).yields null, domainEventsCollectionFake

      store.saveDomainEvent fakeDomainEvent
      .then (domainEvent) ->
        expect(domainEvent.name).to.be.equal fakeDomainEvent.name


    it 'should reject with an error given the database rejects with an error', ->
      eventSourcingConfigResultFake =
        value:
          currentDomainEventId: 1
      eventSourcingConfigCollectionFake =
        findAndModify: sandbox.stub().returns Promise.resolve eventSourcingConfigResultFake

      collectionStub = sandbox.stub store.db, 'collection'
      collectionStub.withArgs('eventSourcingConfig', sandbox.match.func).yields null, eventSourcingConfigCollectionFake

      errorFake = new Error 'errorFake'
      collectionStub.withArgs("#{contextFake.name}.DomainEvents", sandbox.match.func).yields errorFake

      store.saveDomainEvent {}
      .catch (error) ->
        expect(error).to.equal errorFake
