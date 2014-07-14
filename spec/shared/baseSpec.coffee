globals = require '../globals'
sf = require 'safeframe'
Base = require('../../lib/shared/base')

class TestObj extends Base
  constantFields:[
    "foo"
  ]


describe 'TestObj',->
  testObj = null
  beforeEach ->
    testObj = new TestObj()
  describe '#set',->
    it "should set attributes",->
      testObj.set
        one:"one"
        two:"two"
      expect(testObj.attributes).toEqual({one:"one",two:"two"})
    it "should not fire events when silent is set",->
      o =
        f:()->
      spyOn(o,"f")
      testObj.set
        one:"one"
        two:"two"
      ,silent:true
      expect(o.f).not.toHaveBeenCalled()
    it "should throw exception if non object is passed",->
      expect(->testObj.set "test","value").toThrow()
    it "should not set anything if value is undefined",->
      testObj.set(test:undefined)
      expect(Object.keys(testObj.attributes).length).toBe 0
  describe '#change',->
    obj=undefined
    beforeEach ->
      obj =
        change:(sender,changedFields)->
      testObj.change obj.change

    it "should add a function when set",->
      f = ->
      testObj.change(f)
      expect(testObj._events[1]).toBe(f)

    it "should fire all functions when a change is made",->
      spyOn(obj,"change")
      testObj.change(obj.change)
      testObj.set
        one:"one"
        two:"two"

      expect(obj.change).toHaveBeenCalledWith(testObj,["one","two"])
    it "should not fire if a field hasn't been changed",->
      spyOn(obj,"change")
      testObj.change(obj.change)
      testObj.attributes.three="one"
      testObj.attributes.four="two"
      testObj.set
        three:"one"
        four:"two"
      expect(obj.change).not.toHaveBeenCalled()
  describe "#serialize",->
    it "should turn attributes into a query string",->
      testObj.set(foo:"bar",test:"one")
      expect(testObj.serialize()).toBe("foo=bar&test=one")
  describe "#deserialize",->
    it "should deserialize a query string into attributes",->
      testObj.deserialize("foo=bar&test=one")
      expect(testObj.attributes).toEqual(foo:"bar",test:"one")
  describe "#changedFields",->
    it "should return a list of fields that change + fields to always return and clean dirty",->
      testObj.set(foo:"bar",test:"one")
      expect(testObj.changedFields()).toEqual(foo:"bar",test:"one")
      expect(testObj.changedFields()).toEqual(foo:"bar")

