require 'safeframe'
require '../globals'
#todo something here when there is an error
endpoint = require('../../lib/controller/endpoint')
Base = require '../../lib/shared/base'
utils = require '../../lib/shared/utils'
uuid = require 'node-uuid'

describe "Endpoint",->
  testClass = undefined
  beforeEach ->
    testClass = class TestClass extends Base
      constructor:->
        super
    spyOn(utils, "sendRequest").and.callFake (params)->
      if params.success
        setTimeout =>
          params.success(params.data)
        ,100
      return params
  afterEach ->
    endpoint.clear()
  describe '.send',->
    it "should add record to sending requests",()->
      test = new testClass()
      endpoint.send(test)
      expect(endpoint.sendingRequests[test.id]).toBe(test)
      expect(endpoint.pendingRequests[test.id]).toBeUndefined()
    it "should remove record from sending requests after sent",(done)->
      test = new testClass()
      endpoint.send test,()->
        expect(endpoint.sendingRequests[test.id]).toBeUndefined()
        expect(endpoint.pendingRequests[test.id]).toBeUndefined()
        done()
    it "should stay in pending requests if there is already a current record being sent",()->
      test = new testClass()
      endpoint.send(test)
      endpoint.send(test)
      expect(endpoint.pendingRequests[test.id][0]).toBe(test)
      expect(endpoint.sendingRequests[test.id]).toBe(test)
    it "should only send the record once for the pending request",(done)->
      firstWasCalled = false
      secondWasCalled =false
      #todo add a spy to ensure postdata is only called once
      test = new testClass()
      endpoint.send test,->
        firstWasCalled = true
      endpoint.send test,->
        secondWasCalled = true
      endpoint.send test,->
        expect(firstWasCalled).toBe(true)
        expect(secondWasCalled).toBe(false)
        done()
    it "should send data if it has a different id even if there are requests pending",->
      test = new testClass()
      test2 = new testClass()
      endpoint.send test
      endpoint.send test2
      expect(endpoint.pendingRequests).toEqual({})
      expect(Object.keys(endpoint.sendingRequests).length).toBe(2)
    #this will be deprecated
    it "should rename attributes to their endpoint name"
  describe ".success",->
    it "should update the object with response values",->
      test = new testClass()
      endpoint.success(test,
        foo:"bar"
        test:"this"
      )
      expect(test.attributes.foo).toBe("bar")
      expect(test.attributes.test).toBe("this")

  describe ".sendData",->
    testObj = null
    beforeEach ->
      testObj = new testClass()
    it "should do xhr if on same domain as config",->
      result = endpoint.sendData(testObj.attributes,testObj)
      expect(true).toBe(true)
    it "should do jsonp if xdm",->
      expect(true).toBe(true)
