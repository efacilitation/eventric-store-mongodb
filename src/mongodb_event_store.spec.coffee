chai   = require 'chai'
expect = chai.expect

describe 'MongoDB EventStore Adapter', ->
  mongoDBEventStore = null
  saveErr = null
  domainEvent =
    name: 'doSomething'
    aggregate:
      name: 'OurAggregate'

  beforeEach (done) ->
    mongoDBEventStore = require './mongodb_event_store'
    mongoDBEventStore.initialize (err) ->
      mongoDBEventStore.db.collection 'OurAggregate', (err, collection) ->
        collection.remove {}, ->
          mongoDBEventStore.save domainEvent, (err) ->
            saveErr = err
            done()


  afterEach ->
    mongoDBEventStore.db.close()


  describe '#save', ->
    it 'should save the given DomainEvent', ->
      expect(saveErr).to.equal null


  describe '#find', ->
    it 'should find the stored DomainEvent', (done) ->
      mongoDBEventStore.find 'OurAggregate', {}, (err, docs) ->
        expect(docs).to.deep.equal [
          domainEvent
        ]
        done()
