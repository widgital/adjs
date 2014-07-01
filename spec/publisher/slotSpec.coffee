
globals = require '../globals'
sf = require 'safeframe'
Session = require '../../lib/shared/session'
Slot = require '../../lib/publisher/slot'

jasmine.getFixtures().fixturesPath = 'base/spec/fixtures/'

describe 'Slot',->
  session  = null
  beforeEach ->
    session = new Session()
    Slot.destroy()
    sf.host.nuke()
    sf.host.Config
      renderFile:'base/lib/html/adjsframe.html'
      positions:{}
      onStartPosRender: ->
      onFailure: ->
      onAdLoad: (id)->
        Slot(id).load()
      onBeforePosMsg: ()->
      onPosMsg: (id,msg,content)->
        Slot(id).handleMessage(msg,content)
  afterEach ->
    Slot.destroy()
    Session.clearCookie()
  describe '#init',->
    it 'should be called from the Slot(adid)',->
      spyOn(Slot.prototype,"init")
      Slot("testslot")
      expect(Slot::init).toHaveBeenCalledWith("testslot")
    it 'should add a slot to the object',->
      Slot("testslotobj")
      expect(Slot.slots.testslotobj).toBeDefined()
    it 'should retreive the existing slot',->
      retrieved = Slot("testretrieve")
      expect(Slot("testretrieve")).toBe(retrieved)
  describe 'autorefresh',->
    describe '#startAutoRefresh',->
      beforeEach ->
        loadFixtures("publisher/slot.html")
        $("#leaderboard")[0].dataset.refreshTime = 1
        Slot.create($("#leaderboard")[0],session)
        Slot("leaderboard").load ->
          console.log("slot loaded")

      it 'should not start autorefresh until ad has been loaded',()->
        expect(Slot("leaderboard")._isAutoRefreshing).toBeFalsy()
        expect(Slot("leaderboard")._refreshInterval).toBeFalsy()
      it 'should start autorefresh after ad load event',(done)->
        Slot("leaderboard").load ()->
          expect(this._isAutoRefreshing).toBe(true)
          expect(this._refreshInterval).toBeTruthy()
          done()
      it 'should fire the refresh event when it gets refreshed',(done)->
        console.log("prefresh")
        Slot("leaderboard").refreshed ()->
          expect(this.count).toBe(2) #will time out otherwise...
          done()
      it 'should fire the load event after refresh',(done)->
        Slot("leaderboard").refreshed ->
          #only care about second load
          this.load ()->
            expect(this.count).toBe(2)
            done()

    describe '#stopAutoRefresh',->
      it 'should stop autorefresh',(done)->
        Slot("leaderboard").stopAutoRefresh()
        wasRefreshedCalled = false
        Slot("leaderboard").refreshed (slot)->
          wasRefreshedCalled = true
        setTimeout(=>

          expect( Slot("leaderboard")._isAutoRefreshing).toBe(false)
          expect(Slot("leaderboard")._refreshInterval).toBeFalsy()
          expect(wasRefreshedCalled).toBe(false)
          done()
        ,1500)

  describe '#refresh',->
    beforeEach (done)->
      loadFixtures("publisher/slot.html")
      slot = Slot.create($("#leaderboard")[0],session)
      slot.load(done)
    it 'should refresh the ad',(done)->
      Slot("leaderboard").refreshed( ->
        expect(this.count).toBe(2)
        done()
      ).refresh()


#  describe '#trigger',->
#    slot = null
#    beforeEach ->
#      slot = Slot("testslot")
#    it 'should trigger the event for the slot',->
#      o =
#        f: ->
#      slot.on("crap")

#    it 'should trigger the event if set globally',->
#  describe '#handleMessage',->
#    it 'should fire correct events for message',->
#  describe '#initEvents',->
#    it 'should initialize default events',->
#  describe '#notifyFrame',->
#  describe '#create',->
#    it "should create",->
#  describe '#remove',->
#    it "should remove the slot",->
#  describe '#destroy',->
#    it "should destroy the ad",->
#  describe '#reload',->
#    it "should reload the ad",->
#  describe '#currentlyInview',->
#    it "should be inview of > 50 % and viewed"
#    it "should be out of view of not viewed"
#    it "should be out of view if inview percentage < 50"
#  describe '#inviewPercentage',->
#    it "should return the inview percentage"
#  describe '.destroy',->
#    it "should destroy all ads",->
#  describe '.create',->
#    it "should create a slot based on div",->
#  describe '.events',->
#    it "should generate events",->
#    it "should fire an event globally for every instance event",->
#  describe "events",->
#    describe "#load",->
#      it "should fire when no nested iframes",->
#
#      it 'should fire when nested iframes are loaded',->




