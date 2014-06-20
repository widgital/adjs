currentName = window.name
sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
events = require('./shared/event')(["request","load","view","click","expanded","collapsed",
                                    "engage","unview","unload"])
utils = require './shared/utils'
Request = require './request'
stream = require './shared/stream'

do (sf,window)->

  # initialize request
  request = new Request()

  request.change ->
    stream.event request

  sfDom = sf.lib.dom
  AdJS = {}
  VIEWED_STRIKE = 9
  viewedTicks = 0
  unviewedTicks = 0
  width= window.innerWidth
  height= window.innerHeight
  registered = false
  didShow = false
  requested =false

  attributes = {}

  AdJS.setDimensions = (w,h)->
    width = w
    height = h

  registerForEvents = ()->
    registered = true
    $sf.ext.register width,height,onUpdate

  registerAdJSendpoints = ()->
    true

  setSessionInfo = (cookieData)->
    request.set(utils.fromQuery(cookieData))

  updateReferrer = (level="all")->
    switch level
      when "all" then true
      when "host"
        utils.defineProperty document,"referrer",
          get:->
            return "#{document.location.protocol}//#{host}"
        true
      when "none" then false
      else true

  onUpdate = (status,data)->
    switch status
      when "expanded" then  ()-> AdJS.expanded()
      when "collapsed" then  ()-> AdJS.collapsed()
      when "geom-update" then showAd()
      when "cookie-update" then setSessionInfo(unescape(data.value))
      when "engaged" then AdJS.engage()
      when "requested" then AdJS.request()  unless requested

  isViewedInterval =null

  updateIsViewed = ->
    if !AdJS.isViewed && $sf.ext.inViewPercentage?() > 50 && $sf.ext.winHasFocus()
      viewedTicks++
    else if AdJS.isViewed &&  ($sf.ext.inViewPercentage?() < 50 || !$sf.ext.winHasFocus())
      unviewedTicks++
    else
      unviewedTicks = viewedTicks = 0
    if viewedTicks == VIEWED_STRIKE
      AdJS.view() unless AdJS.isViewed
      AdJS.isViewed=true
    if unviewedTicks == VIEWED_STRIKE
      AdJS.unview() unless AdJS.isunViewed
      AdJS.isunViewed = true
      clearInterval(isViewedInterval)

  showAdTimer = null

  showAd = (show)->
    if ($sf.ext.inViewPercentage?() > 5 && !didShow) or show
      clearInterval(showAdTimer) if showAdTimer
      startTime = utils.now()
      AdJS.request()
      $sf.ext.showAd ->
        AdJS.load()
      didShow=true
    else unless showAdTimer || didShow
      showAdTimer = setInterval(forceNuke,50)

  forceNuke = ()->
    if ($sf.ext.inViewPercentage?() > 5 && showAdTimer)
      clearInterval(showAdTimer)
      showAdTimer=null
      $sf.ext.reload()

  sf.lib.lang.mix(AdJS,events)

  AdJS.on = (event,cb)->
    #registerForEvents() if not registered
    events.on.apply(@,[event,cb])

  AdJS.expand = (deltaXorDesc, deltaY, p)-> $sf.ext.expand(deltaXorDesc,deltaY,p)
  AdJS.collapse = -> $sf.ext.collapse()
  AdJS.cookie = (cookieName,cookieData)-> $sf.ext.cookie(coookieName,cookieData)
  AdJS.supports = (key)-> $sf.ext.supports(key)
  AdJS.sendMessage = (content)->
    setTimeout(->
      $sf.ext.message(encodeURIComponent(content))
    ,1)
  sfDom.attach(document.body,"mouseup",->
    AdJS.click()
    true
  )

  window.$ad = AdJS

  registerAdJSendpoints()

  AdJS.click ->
    sf.ext.click()

  AdJS.view  ->
    sf.ext.viewed()

  AdJS.unview ->
    sf.ext.unviewed()

  AdJS.load ->
    registerForEvents()

  AdJS.load ->
    isViewedInterval = setInterval(updateIsViewed,100)

  AdJS.load ->
    AdJS.frameCount = utils.countFrames(window)
    request.set(frame_count:AdJS.frameCount)

  AdJS.request ->
    AdJS.requestTime = utils.now()
    request.set
      requested:true
      requestedAt:utils.now()

  AdJS.load ->
    AdJS.loadTime = utils.now()
    sfDom.attach window,"unload",->
      $ad.unload()
    request.set
      loaded:true
      loadedAt:utils.now()

  AdJS.view ->
    AdJS.viewTime = utils.now()
    request.set
      viewed:true
      viewedAt:utils.now()

  AdJS.engage ->
    AdJS.engageTime = utils.now()
    request.set
      engaged:true
      engagedAt:utils.now()

  AdJS.click ->
    AdJS.clickTime = utils.now()
    request.set
      clicked:true
      clickedAt:utils.now()

  AdJS.unview ->
    AdJS.unviewTime = utils.now()
    request.set
      unviewed:true
      unviewedAt:utils.now()

  AdJS.unload ->
    AdJS.unloadTime = utils.now()
    request.set
      unloaded:true
      unloadedAt:utils.now()

  sf.ext.render(false)
  didShow = not sf.lib.lang.cbool(sf.ext.meta("inview","extended"))
  referrerLevel = sf.ext.meta("referrer","extended") or "all"
  host = sf.ext.meta("host","extended")
  sf.ext.deleteMeta("host","extended")
  location = sf.ext.meta("location","extended")
  sf.ext.deleteMeta("location","extended")
  setSessionInfo sf.ext.meta("session","extended"),silent:true
  sf.ext.deleteMeta("session","extended")
  $ad.slotId = sf.ext.meta("slot_id","extended")
  $ad.count =  sf.ext.meta("slot_count","extended")
  request.set
    slot_id:  sf.ext.meta("slot_id","extended")
    slot_count: sf.ext.meta("slot_count","extended"),
    page_url: location
    page_host: host
    {silent:true}
  showPage = document.location.href == document.referrer or updateReferrer(referrerLevel)
  if showPage
    showAd(didShow)
  else
    window.name = currentName
    document.location = document.location

  AdJS