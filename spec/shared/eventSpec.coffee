sf = require 'safeframe'
event = require('../../lib/shared/event')(['test1','test2'])
class TestEvent
  constructor:->

sf.lib.lang.mix(TestEvent::,event)
describe 'event',->
  testObj = null
  beforeEach ->
    testObj = new TestEvent()
  describe '.trigger',->
    it 'should call a function when an event occurs',->
      testVal = undefined
      data = undefined
      optionalData = undefined
      testObj.on "testEvent",(d,od)->
        testVal = "set"
        data =d
        optionalData=od
      testObj.trigger("testEvent","data","optionalData")
      expect(testVal).toBe("set")
      expect(data).toBe("data")
      expect(optionalData).toBe("optionalData")
  describe '.on',->
    it 'should add a function to an event',->
      f = ()->
      testObj.on("testEvent",f)
      expect(testObj.events["testEvent"][0]).toBe(f)
  describe 'named events',->
    it 'should define named events',->
      expect(typeof testObj.test1).toEqual("function")
    it 'should add named events',->
      f = ()->
      testObj.test1(f)
      expect(testObj.events["test1"][0]).toBe(f)
    it 'should trigger named events',->
      obj =
        f:()->
      spyOn(obj,"f")
      testObj.test1(obj.f)
      testObj.test1()
      expect(obj.f).toHaveBeenCalled();