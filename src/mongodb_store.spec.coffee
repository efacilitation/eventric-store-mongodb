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


  describe 'having a mongo.dbInstance', ->

    describe '#initialize', ->

      it 'should not call MongoClient.connect', (done) ->
        sandbox.spy MongoClient, 'connect'
        options =
          dbInstance: sandbox.stub()
        mongoDbStore.initialize name: 'exampleContext', options
        .then ->
          expect(MongoClient.connect).to.not.have.been.called
          done()


  describe 'having no mongo.dbInstance', ->

    options = null
    domainEvent =
      name: 'SomethingHappened'
      aggregate:
        id: 23
        name: 'Example'

    before ->
      options =
        database: '__eventric_tests'
      sandbox.spy MongoClient, 'connect'
      mongoDbStore.initialize name: 'exampleContext', options


    beforeEach (done) ->
      mongoDbStore.db.dropDatabase ->
        done()


    after ->
      mongoDbStore.db.close()


    describe '#initialize', ->
      it 'should call the MongoClient.connect with the correct options', ->
        expect(MongoClient.connect).to.have.been.calledWith 'mongodb://127.0.0.1:27017/__eventric_tests'


    describe 'domain events', ->

      describe '#saveDomainEvent', ->

        it 'should save the given doc', ->
          mongoDbStore.saveDomainEvent domainEvent
          .then (domainEvents) ->
            expect(domainEvents.ops[0]._id).to.be.ok


      describe 'find', ->

        beforeEach ->
          mongoDbStore.saveDomainEvent domainEvent


        describe '#findDomainEventsByName', ->

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


    describe 'projection stores', ->

      describe '#getProjectionStore', ->

        it 'should callback with the collection', ->
          mongoDbStore.getProjectionStore 'exampleProjection'
          .then (collection) ->
            expect(collection).to.be.an.instanceof mongodb.Collection


      describe '#clearProjectionStore', ->

        beforeEach (done) ->
          mongoDbStore.getProjectionStore 'exampleProjection'
          .then (projectionStore) ->
            projectionStore.insert domainEvent, ->
              done()


        it 'should callback after removing', (done) ->
          mongoDbStore.clearProjectionStore 'exampleProjection'
          .then ->
            mongoDbStore.db.collection('system.namespaces').find().toArray (err, items) ->
              expect(items.length).to.equal 1
              done()
