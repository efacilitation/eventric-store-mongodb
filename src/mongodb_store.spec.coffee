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


  describe 'given we got a mongo.dbInstance', ->
    describe '#initialize', ->
      it 'should not call MongoClient.connect', (done) ->
        sandbox.spy MongoClient, 'connect'
        options =
          dbInstance: sandbox.stub()
        mongoDbStore.initialize 'exampleContext', options, ->
          expect(MongoClient.connect).to.not.have.been.called
          done()


  describe 'given we got no mongo.dbInstance', ->
    options = null
    domainEvent =
      name: 'SomethingHappened'
      aggregate:
        id: 23
        name: 'Example'

    before (done) ->
      options =
        database: '__eventric_tests'
      sandbox.spy MongoClient, 'connect'
      mongoDbStore.initialize 'exampleContext', options, (err) ->
        done()


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
        it 'should save the given doc', (done) ->
          mongoDbStore.saveDomainEvent domainEvent, (err, domainEvents) ->
            expect(err).to.be.null
            expect(domainEvents[0]._id).to.be.ok
            done()


      describe 'find', ->
        beforeEach (done) ->
          mongoDbStore.saveDomainEvent domainEvent, ->
            done()


        describe '#findAllDomainEvents', ->
          it 'should find the previously saved domainevent', (done) ->
            mongoDbStore.findAllDomainEvents (err, domainEvents) ->
              expect(domainEvents).to.deep.equal [
                domainEvent
              ]
              done()


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


        describe '#findDomainEventsByAggregateName', ->
          it 'should find the previously saved domainevent', (done) ->
            mongoDbStore.findDomainEventsByAggregateName 'Example', (err, domainEvents) ->
              expect(domainEvents).to.deep.equal [
                domainEvent
              ]
              done()


          it 'should find the previously saved domainevent', (done) ->
            mongoDbStore.findDomainEventsByAggregateName ['Example'], (err, domainEvents) ->
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
        it 'should callback with the collection', (done) ->
          mongoDbStore.getProjectionStore 'exampleProjection', (err, collection) ->
            expect(collection).to.be.an.instanceof mongodb.Collection
            done()


      describe '#clearProjectionStore', ->
        it 'should callback after removing', (done) ->
          mongoDbStore.clearProjectionStore 'exampleProjection', ->
            mongoDbStore.db.collection('system.namespaces').find().toArray (err, items) ->
              expect(items.length).to.equal 0
              done()
