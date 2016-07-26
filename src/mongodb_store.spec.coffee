require('es6-promise').polyfill()
chai      = require 'chai'
expect    = chai.expect
sinon     = require 'sinon'
sandbox   = sinon.sandbox.create()
sinonChai = require 'sinon-chai'
chai.use sinonChai

mongodb = require('mongodb')
MongoClient = mongodb.MongoClient

describe 'MongoDB Store Adapter', ->
  mongoDbStore = null

  before ->
    MongoDbStore = require './mongodb_store'
    mongoDbStore = new MongoDbStore


  afterEach ->
    sandbox.restore()


  describe 'given a mongo.dbInstance', ->

    describe '#initialize', ->

      it 'should not call MongoClient.connect', ->
        sandbox.spy MongoClient, 'connect'
        options =
          dbInstance: sandbox.stub()
        mongoDbStore.initialize name: 'exampleContext', options
        .then ->
          expect(MongoClient.connect).to.not.have.been.called


  describe 'given no mongo.dbInstance', ->

    options = null
    domainEvent =
      name: 'SomethingHappened'
      aggregate:
        id: 23
        name: 'Example'

    before ->
      options =
        database: 'eventric_store_mongodb_specs'
      sandbox.spy MongoClient, 'connect'
      mongoDbStore.initialize name: 'exampleContext', options


    beforeEach ->
      mongoDbStore.db.dropDatabase()


    after ->
      mongoDbStore.db.close()


    describe '#initialize', ->

      it 'should call the MongoClient.connect with the correct options', ->
        expect(MongoClient.connect).to.have.been.calledWith 'mongodb://127.0.0.1:27017/eventric_store_mongodb_specs'


    describe '#saveDomainEvent', ->

      it 'should save the given doc', ->
        mongoDbStore.saveDomainEvent domainEvent
        .then (domainEvents) ->
          expect(domainEvents.ops[0]._id).to.be.ok


    describe '#findDomainEventsByName', ->

      beforeEach ->
        mongoDbStore.saveDomainEvent domainEvent


      it 'should find the previously saved domain event given the name as string', (done) ->
        mongoDbStore.findDomainEventsByName 'SomethingHappened', (error, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


      it 'should find the previously saved domain event given the name as array', (done) ->
        mongoDbStore.findDomainEventsByName ['SomethingHappened'], (error, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


    describe '#findDomainEventsByAggregateId', ->

      beforeEach ->
        mongoDbStore.saveDomainEvent domainEvent


      it 'should find the previously saved domain event given an id', (done) ->
        mongoDbStore.findDomainEventsByAggregateId 23, (error, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


      it 'should find the previously saved domain event given the id as array', (done) ->
        mongoDbStore.findDomainEventsByAggregateId [23], (error, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


    describe '#findDomainEventsByNameAndAggregateId', ->

      beforeEach ->
        mongoDbStore.saveDomainEvent domainEvent


      it 'should find the previously saved domain event given a name and an id', (done) ->
        mongoDbStore.findDomainEventsByNameAndAggregateId 'SomethingHappened', 23, (error, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


      it 'should find the previously saved domain event given the name and id as array', (done) ->
        mongoDbStore.findDomainEventsByNameAndAggregateId ['SomethingHappened'], [23], (error, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


    describe '#getProjectionStore', ->

      it 'should resolve with the collection', ->
        mongoDbStore.getProjectionStore 'exampleProjection'
        .then (collection) ->
          expect(collection).to.be.an.instanceof mongodb.Collection


    describe '#clearProjectionStore', ->

      it 'should resolve after removing given the collection is available', (done) ->
        mongoDbStore.getProjectionStore 'exampleProjection'
        .then (projectionStore) ->
          readModel =
            id: '2a2176e0-1a52-de63-3562-4cebfd3f10e1'
            exampleKey: 'exampleValue'
          projectionStore.insert readModel
          .then ->
            mongoDbStore.clearProjectionStore 'exampleProjection'
            .then ->
              mongoDbStore.db.collection('system.namespaces').find().toArray()
              .then (items) ->
                expect(items.length).to.equal 1
                done()
            .catch done
        .catch done


      it 'should resolve after removing given the collection is not available', (done) ->
        mongoDbStore.clearProjectionStore 'exampleProjection'
        .then ->
          mongoDbStore.db.collection('system.namespaces').find().toArray (error, items) ->
            expect(items.length).to.equal 0
            done()
        .catch done
