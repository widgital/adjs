sf =  require 'safeframe'
engagement = require './shared/engagement'
Session = require './shared/session'
AdJS = require './publisher/slot'
stream = require './shared/stream'
config = require './shared/config'
utils  =require './shared/utils'

do (window)->
  # initialize session
  session = new Session()
  session.incr("p")
  startTicks = utils.now()
  pageLoadMs = 0
  pageDuration = 0


  # Notify of new page, set the page ID
  stream.page session


  safeframeUrl = config.cdn_url
#  if process.env.ENV == "production"
#    safeframeUrl = process.env.CDN_URL
#  else
#    safeframeUrl = "../lib/html/adjsframe.html"
  sfDom =  $sf.lib.dom
  sfDom.attach "beforeunload",->
    pageDuration =  utils.now()-startTicks
    true
  globalConfig =
    keys:[]
    safeframe_url: safeframeUrl

  doRender = (cb)->
    sfPositions  = {}
    if !sfDom.ready()
      sfDom.wait ->
        pageLoadMs = (utils.now() - startTicks)
        doRender.apply null, args
        args = null
      return
    else
      divs = (div for div in document.getElementsByTagName("div"))
      for d in divs when sfDom.attr(d,"data-adjs")
        do (d)->
          AdJS.create(d,session)
      cb?()

  initSafeFrame =  ->
    $sf.host.Config
      renderFile:globalConfig.safeframe_url
      positions:{}
      onStartPosRender: ->
      onFailure: ->
      onAdLoad: (id)->
        AdJS(id).load()
      onBeforePosMsg: ()->
      onPosMsg: (id,msg,content)->
        AdJS(id).handleMessage(msg,content)

  AdJS.view ->
    session.incr("av") #increment on any ad view
  AdJS.engage ->
    session.incr("ae")
  AdJS.load ->
    session.incr("a")
  AdJS.click ->
    session.incr("ac")
  AdJS.load ->
    console.log("loaded")

  session.change ->
    for _,ad of AdJS.slots
      ad.notifyFrame("cookie-update",session.serializeCookie())

  AdJS.render = (cb)->
    adJsScript = (s for s in document.getElementsByTagName("script") when sfDom.attr(s,"data-adjs"))[0]
    clientId = sfDom.attr(adJsScript,"data-client-id")
    session.set("client_id",clientId)
    initSafeFrame()
    doRender()
  #session events

  engagement.onEngagement ->
    for _,ad of AdJS.slots
      if ad.currentlyInview() && !ad.engaged
        ad.engage()

  do ->
    AdJS.render()
#  AdJS.sizes= sizes
  AdJS.session = session


  window.$ad = AdJS
  AdJS