cookies = require 'cookies-js'
uuid = require 'node-uuid'
Base = require './base'
utils = require './utils'
config = require './config'
moment = require 'moment'

module.exports = do ($sf,window)->

  COOKIE_KEY = "_ajsk"

  class Page extends Base
    constructor:(serializedParams)->
      super()
      if serializedParams
        @deserialize(serializedParams)
      else
        @loadCookieData()
        @initDefaultAttributes()
    storeCookie:->
      #use milliseconds for the expiration to allow for easier testing
      if $sf?.ext?.cookie?
        $sf.ext.cookie("#{COOKIE_KEY}_suid",
          {value:@attributes.site_user_id,expires:moment().add("years",1).toDate()}) if @attributes.site_user_id
        $sf.ext.cookie("#{COOKIE_KEY}_vid",
          {value:@attributes.visit_id,expires:moment().add("seconds",config.visit_expiry*60).toDate()}) if @attributes.visit_id
      else
        cookies.set("#{COOKIE_KEY}_suid" ,
          @attributes.site_user_id, { expires:moment().add("years",1).toDate()   }) if @attributes.site_user_id #one year
        cookies.set("#{COOKIE_KEY}_vid" ,
          @attributes.visit_id, { expires:moment().add("seconds",config.visit_expiry*60).toDate()}) if @attributes.visit_id
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
    set:(attrs,options={})->
      super(attrs,options)
      @storeCookie()
    initDefaultAttributes:->
      if window==window.top
        @set
          full_url:window.document.location.href
          referrer:window.document.referrer
        ,silent:true
      else if window.parent==window.top
        @set
          full_url:window.document.referrer
    verifyUrl:->
      if  window.parent==window.top && window.document.referrer #this shouldnt be neccasary but whatevs
        true #some of this should be done on the serer
    path:"/page"
    constantFields:[
      "site_user_id",
      "page_id",
      "visit_id",
      "full_url"
    ]
  Page.VISITOR_EXPIRY = config.visit_expiry #20 seconds...

  if process.env.ENV == "test" or (_TEST? and _TEST)
    Page._COOKIE_KEY  = COOKIE_KEY
    Page.clearCookie = ->
      cookies.set(COOKIE_KEY + "_suid",undefined)
      cookies.set(COOKIE_KEY + "_vid",undefined)
  return Page


