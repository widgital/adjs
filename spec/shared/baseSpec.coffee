globals = require '../globals'
sf = require 'safeframe'
Base = require('../../lib/shared/base')

class TestObj extends Base


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

