globals = require '../globals'
sf = require 'safeframe'
utils = require '../../lib/shared/utils'
Page = require '../../lib/shared/page'
cookies = require 'cookies-js'
#Slot = require '../../lib/publisher/slot'


describe 'Page',->
  beforeEach ()->
    Page.clearCookie()
  afterEach ()->
    Page.clearCookie()

  describe '#constructor',->
    it "should set default attributes",->
      page = new Page()
      expect(page.attributes).toEqual
        url: document.location.href
        ref: document.referrer
        v_js : '0.0.1'
    it "should load from query string and not set default attributes",->
      page = new Page("site_user_id=jason&visit_id=fertel&url=http%3A%2F%2Fwww.example.com%2Ftest")
      expect(page.attributes).toEqual
        site_user_id: "jason"
        url: "http://www.example.com/test"
        visit_id: "fertel"
    it "should store cookie",->
      page = new Page("site_user_id=jason&visit_id=fertel")
      siteUserID = cookies.get("#{Page._COOKIE_KEY}_suid")
      visitorId = cookies.get("#{Page._COOKIE_KEY}_vid")
      expect(siteUserID).toEqual("jason")
      expect(visitorId).toEqual("fertel")
  describe "#storeCookie",->
    it "should store the cookie",->
      page = new Page()
      page.attributes.site_user_id = "jason"
      page.attributes.visit_id = "fertel"
      page.storeCookie()
      visitorId = cookies.get("#{Page._COOKIE_KEY}_vid")
      siteUserID = cookies.get("#{Page._COOKIE_KEY}_suid")
      expect(visitorId).toEqual("fertel")
      expect(siteUserID).toEqual("jason")
    it "should expire visit_id cookie",(done)->
      #expiry is .002
      page = new Page("site_user_id=jason&visit_id=fertel")
      setTimeout ->
        visitorId = cookies.get("#{Page._COOKIE_KEY}_vid")
        expect(visitorId).toBeUndefined()
        done()
      ,2000
    xit "should store the cookie of the top window if in a safeframe"
  describe '#set',->
    it "should set cookie",->
      page = new Page()
      page.set(site_user_id:"jason")
      page = new Page()
      expect(page.attributes.site_user_id).toBe("jason")
