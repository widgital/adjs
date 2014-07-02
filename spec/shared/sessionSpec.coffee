globals = require '../globals'
sf = require 'safeframe'
utils = require '../../lib/shared/utils'
Session = require '../../lib/shared/session'
cookies = require 'cookies-js'


describe 'Session',->
  beforeEach ()->
    Session.clearCookie()
  afterEach ()->
    Session.clearCookie()



  describe '._updateVisitId',->
    session = undefined
    beforeEach ->
      session = new Session()
    it 'should not update visit id if last_updated < Visitor expiry should update lastvisit time',->
      oldVisitId = session.attributes.vid
      console.log(session.attributes.vts,utils.now()/1000)
      Session._updateVisitId.call(session)

      expect(session.attributes.vid).toBe(oldVisitId)
      expect(session.attributes.v).toBe(1)
    it 'should update visit id if last updated > VISITOR_EXPIRY',->
      session.lastVisitTime = (utils.now()/1000) - 100
      oldVisitId = session.attributes.vid
      Session._updateVisitId.call(session)
      expect(session.attributes.vid).not.toEqual(oldVisitId)
      expect(session.attributes.v).toBe(2)

  describe '#constructor',->

    it "should set default values if no cookie",->

      session = new Session()
      defaultAttributes =
        id: ''
        vid: ''
        ts: ''
        p: 0
        a: 0
        av: 0
        ac: 0
        ae: 0
        v: 1   #need to figure this out...
        vts: ''
        vts0: ''
        vp: 0
        va: 0
        vav: 0
        vae: 0
        vac: 0
      defaultAttributes.vts = session.attributes.vts
      defaultAttributes.vts0 = session.attributes.vts0
      defaultAttributes.id = session.attributes.id
      defaultAttributes.vid = session.attributes.vid
      defaultAttributes.ts = session.attributes.ts
      expect(session.attributes).toEqual(defaultAttributes)
    it "should load user data from passed query",->
      changeAttrs =
        vts: (utils.now()/1000)
        id: "ABCDE"
        vid: "XYZ"
        ac: 10
        vav: 101

      query = utils.toQuery(changeAttrs)
      delete changeAttrs.vts
      session = new Session(query)
      for k,v of changeAttrs
        if typeof v == "number"
          expect(utils.toNumber(session.attributes[k])).toEqual(v)
        else
          expect(session.attributes[k]).toEqual(v)
    it "should load user data from cookie",->
      changeAttrs =
        vts: (utils.now()/1000)
        id: "TTESTID"
        vid: "TTESTVID"
        ac: 10
        vav: 101
      query = utils.toQuery(changeAttrs)
      cookies.set(Session._COOKIE_KEY,query, { expires: 31536000  }) #one year
      session= new Session()
      delete changeAttrs.vts
      for k,v of changeAttrs
        if typeof v == "number"
          expect(utils.toNumber(session.attributes[k])).toEqual(v)
        else
          expect(session.attributes[k]).toEqual(v)
    it "should update visit id if expired",->
      changeAttrs =
        vts: (utils.now()/1000) - 1000
        vid: "XYZ"
      query = utils.toQuery(changeAttrs)
      session = new Session(query)
      expect(session.attributes.vts).not.toEqual(changeAttrs.vid)
    it "should store cookie",->
      Session.clearCookie()
      session = new Session()
      cookie = cookies.get(Session._COOKIE_KEY)
      expect(cookie).toBeTruthy()
  describe "#incr",->
    it "should increment the key + visitor key",()->
      session = new Session()
      session.incr("av")
      expect(session.attributes.av).toBe(1)
      expect(session.attributes.vav).toBe(1)
    it "should call set",->
      session = new Session()
      spyOn(session,"set")
      session.incr("av")
      expect(session.set).toHaveBeenCalled()
  describe '#set',->
    it "should serialize cookie",->
      session = new Session()
      session.set(av:200)
      session = new Session()
      expect(session.attributes.av).toBe("200")
