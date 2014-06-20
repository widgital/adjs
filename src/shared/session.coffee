cookies = require 'cookies-js'
uuid = require 'node-uuid'
Base = require './base'
utils = require './utils'
module.exports = do ->

  COOKIE_KEY = "_ajsk"
  now = utils.now()
  #  u1 = id|ts|p|a|av|ae|ac|v|vts|vts0|vp|va|vav|vae|vac

  #  id = user id
  #  ts = timestamp when id created
  #  p = total number of page views
  #  a = total number of ads requested
  #  av = total number of ads viewed
  #  ae = number of ads viewed w/ engagement
  #  ac = number of total ads clicked
  #  v = number of total visits (new visit when 30 min of inactivity)
  #  vts = timestamp when visit created
  #  vts0 = timestamp when previous visit created
  #  vp = total number of page views
  #  va = total number of ads requested
  #  vav = total number of ads viewed
  #  vae = number of ads viewed w/ engagement
  #  vac = number of total ads clicked
  #
  #  id = user id
  #ts = timestamp when id created
  #p = total number of page views
  #a = total number of ads requested
  #av = total number of ads viewed
  #ae = number of ads viewed w/ engagement
  #ac = number of total ads clicked
  #v = number of total visits (new visit when 30 min of inactivity)
  #vts = timestamp when visit created
  #vts0 = timestamp when previous visit created
  #vp = total number of page views
  #va = total number of ads requested
  #vav = total number of ads viewed
  #vae = number of ads viewed w/ engagement
  #vac = number of total ads clicked

  updateVisitId = (options)->
    nowTime = utils.now()/1000
    @lastVisitTime ||= utils.toNumber(@attributes.vts,0)
    if (nowTime - Session.VISITOR_EXPIRY) > @lastVisitTime
      @set
        v: utils.toNumber(@attributes.v) + 1
        vts0:@attributes.vts
        vts:nowTime
        vid:uuid.v4()
        vp:0
        va:0
        vav:0
        vae:0
        vac:0
        ,options
    else
      @lastVisitTime = nowTime
      @set(vts:nowTime,{silent:true})
  parseCookie = (cookie)->
    utils.fromQuery(cookie)
  getUserId = ()->
    utils.sendRequest()
  defaultAttributes = ()->
    id: uuid.v4()
    vid: uuid.v4()
    ts: now/1000
    p: 0
    a: 0
    av: 0
    ac: 0
    ae: 0
    v: 1
    vts: now/1000
    vts0: now/1000
    vp: 0
    va: 0
    vav: 0
    vae: 0
    vac: 0
  class Session extends Base
    constructor:(query)->
      super()
      for k,v of defaultAttributes()
        @attributes[k] or= v

      if query
        attrs = parseCookie(query)
        @set(attrs,silent:true)
      else if cookie = cookies.get(COOKIE_KEY)
        attrs = parseCookie(cookie)
        @set(attrs,silent:true)
        updateVisitId.call(@,silent: true)
        @serializeCookie()
      else
        @serializeCookie()

    serializeCookie:->
      query = utils.toQuery(@attributes)
      cookies.set(COOKIE_KEY,query, { expires: 31536000  }) #one year
      query
    set:(attrs,options={})->
      super(attrs,options)
      @serializeCookie()
    incr:(key,options)->
      @attributes[key] ||=0
      updatedVals = {}
      updatedVals[key] = utils.toNumber(@attributes[key])+1
      vkey = "v#{key}"
      if @attributes[vkey]?
        updatedVals[vkey] =  utils.toNumber(@attributes[vkey])+1
      @set(updatedVals,options)
  Session.VISITOR_EXPIRY = 20 #20 seconds...

  if _TEST? and _TEST
    Session._updateVisitId = updateVisitId
    Session._parseCookie = parseCookie
    Session._getUser = getUserId
    Session._COOKIE_KEY  = COOKIE_KEY
    Session.clearCookie = ->
      cookies.set(COOKIE_KEY,undefined)
  return Session


