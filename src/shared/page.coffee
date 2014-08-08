cookies = require 'cookies-js'
uuid = require 'node-uuid'
#[Base](./base.html)
Base = require './base'
#[Utils](./utils.html)
utils = require './utils'
#[Config](./config.html)
config = require './config'
moment = require 'moment'

module.exports = do ($sf,window)->

  COOKIE_KEY = "_ajsk"
  #page class that logs page level events such as views
  class Page extends Base
    #handle a list of serialized params -since this object is used both within the
    # frame and outside this data is passed in the controller constructor
    constructor:(serializedParams)->
      super()
      if serializedParams
        @deserialize(serializedParams)
      else
        @loadCookieData()
        @initDefaultAttributes()
    # store the cookie either using the controller to set it or using the publisher page
    storeCookie:->
      #use milliseconds for the expiration to allow for easier testing
      if $sf?.ext?.cookie?
        $sf.ext.cookie("#{COOKIE_KEY}_suid",
          {value:@attributes.site_user_id,expires:moment().add("years",1).toDate()}) if @attributes.site_user_id
        $sf.ext.cookie("#{COOKIE_KEY}_vid",
          {value:@attributes.visit_id,expires:moment().add("seconds",config.visit_expiry*60).toDate()}) if @attributes.visit_id
        #set a local cookie to see if it works on the backend
        cookies.set("#{COOKIE_KEY}_enabled","true",domain: window.document.domain)
      else
        cookies.set("#{COOKIE_KEY}_suid" ,
          @attributes.site_user_id, { expires:moment().add("years",1).toDate()   }) if @attributes.site_user_id #one year
        cookies.set("#{COOKIE_KEY}_vid" ,
          @attributes.visit_id, { expires:moment().add("seconds",config.visit_expiry*60).toDate()}) if @attributes.visit_id
    # load the cookie if in the ext frame - or on the pub page
    loadCookieData:->
      if $sf?.ext?.cookie?
        @set
          site_user_id:$sf.ext.cookie("#{COOKIE_KEY}_suid")
          visit_id:$sf.ext.cookie("#{COOKIE_KEY}_vid")
        ,silent:true
      else
        @set
          site_user_id:cookies.get("#{COOKIE_KEY}_suid")
          visit_id:cookies.get("#{COOKIE_KEY}_vid")
        ,silent:true
    #override set to store cookie after every set
    set:(attrs,options={})->
      super(attrs,options)
      @storeCookie()
    #grap the url info if on the top
    initDefaultAttributes:->
     attrs = if window==window.top
        url:window.document.location.href
        ref:window.document.referrer
      else if window.parent==window.top
        url:window.document.referrer
     attrs.v_js = config.version
     attrs.tz = (new Date()).getTimezoneOffset()
     @set attrs,silent:true


    #todo: properly verify the url if not top
    verifyUrl:->
      if  window.parent==window.top && window.document.referrer #this shouldnt be neccasary but whatevs
        true #some of this should be done on the serer
    #helper function to serialize attributes that break on paramshash
    serializedAttributes:()->
      outAttrs = {}
      for k,v of @attributes
        outAttrs[k] = v
      outAttrs.url = encodeURIComponent(outAttrs.url)
      outAttrs.ref = encodeURIComponent(outAttrs.ref)
      outAttrs
    deserialize:(params)->
      super(params)
      @set
        url:decodeURIComponent(@attributes.url)
        ref:decodeURIComponent(@attributes.ref)
      ,silent:true

    path:"/page"
    constantFields:[
      "site_user_id",
      "page_id",
      "visit_id",
      "url"
    ]
  if process.env.ENV == "test" or (_TEST? and _TEST)
    Page._COOKIE_KEY  = COOKIE_KEY
    Page.clearCookie = ->
      cookies.set(COOKIE_KEY + "_suid",undefined)
      cookies.set(COOKIE_KEY + "_vid",undefined)
  return Page


