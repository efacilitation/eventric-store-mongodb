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

      it 'should not call MongoClient.connect', (done) ->
        sandbox.spy MongoClient, 'connect'
        options =
          dbInstance: sandbox.stub()
        mongoDbStore.initialize name: 'exampleContext', options
        .then ->
          expect(MongoClient.connect).to.not.have.been.called
          done()


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


    beforeEach (done) ->
      mongoDbStore.db.dropDatabase ->
        done()


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


      it 'should find the previously saved domainevent', (done) ->
        mongoDbStore.findDomainEventsByName 'SomethingHappened', (err, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


      it 'should find the previously saved domainevent', (done) ->
        mongoDbStore.findDomainEventsByName ['SomethingHappened'], (err, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


    describe '#findDomainEventsByAggregateId', ->

      beforeEach ->
        mongoDbStore.saveDomainEvent domainEvent


      it 'should find the previously saved domainevent', (done) ->
        mongoDbStore.findDomainEventsByAggregateId 23, (err, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


      it 'should find the previously saved domainevent', (done) ->
        mongoDbStore.findDomainEventsByAggregateId [23], (err, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


    describe '#findDomainEventsByNameAndAggregateId', ->

      beforeEach ->
        mongoDbStore.saveDomainEvent domainEvent


      it 'should find the previously saved domainevent', (done) ->
        mongoDbStore.findDomainEventsByNameAndAggregateId 'SomethingHappened', 23, (err, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


      it 'should find the previously saved domainevent', (done) ->
        mongoDbStore.findDomainEventsByNameAndAggregateId ['SomethingHappened'], [23], (err, domainEvents) ->
          expect(domainEvents).to.deep.equal [
            domainEvent
          ]
          done()


    describe '#getProjectionStore', ->

      it 'should callback with the collection', ->
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
          projectionStore.insert readModel, ->
            mongoDbStore.clearProjectionStore 'exampleProjection'
            .then ->
              mongoDbStore.db.collection('system.namespaces').find().toArray (err, items) ->
                expect(items.length).to.equal 1
                done()
            .catch done
        .catch done


      it 'should resolve after removing given the collection is not available', (done) ->
        mongoDbStore.clearProjectionStore 'exampleProjection'
        .then ->
          mongoDbStore.db.collection('system.namespaces').find().toArray (err, items) ->
            expect(items.length).to.equal 0
            done()
        .catch done
