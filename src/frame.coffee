currentName = window.name

$sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
events = require('./shared/event')(["request","load","view","click","expanded","collapsed",
                                    "engage","unview","unload"])
utils = require './shared/utils'
Request = require './request'
stream = require './shared/stream'
config = require './shared/config'

do ($sf,window)->

  # initialize request
  document.domain = config.domain
  controller = null
  sfDom = $sf.lib.dom
  AdJS = {}
  utils.defineProperty AdJS,"isController",
    writable:false
    value:false
    configurable:false


  request = new Request()
  request.set
    load_pos:utils.getFramePosition(window)
    v_js:config.version
    req_url_blind: true #todo this will not always be true
    tz:(new Date()).getTimezoneOffset()
  findController = ->
    for frame in window.parent.frames
      try
        if frame.$ad?.isController
          controller = frame.$ad
          request.change ->
            controller.send(request)
          controller.send(request)
          return
      catch
    setTimeout(findController,100) unless controller
  findController()




#
#  request.change ->
#    stream.event request
#  stream.event request



  VIEWED_STRIKE = 9
  viewedTicks = 0
  unviewedTicks = 0
  width= window.innerWidth
  height= window.innerHeight
  registered = false
  didShow = false
  requested =false
  startTicks = utils.now()
  maxViewPercentage = 0
  viewedPercentages = []

  attributes = {}

  AdJS.setDimensions = (w,h)->
    width = w
    height = h

  registerForEvents = ()->
    registered = true
    $sf.ext.register width,height,onUpdate

  registerAdJSendpoints = ()->
    true


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
      when "engaged" then AdJS.engage()
      when "requested" then AdJS.request()  unless requested

  isViewedInterval =null

  updateIsViewed = ->
    viewPercent = $sf.ext.inViewPercentage?() or 0
    if !AdJS.isViewed && viewPercent > 50 && $sf.ext.winHasFocus()
      viewedTicks++
      viewedPercentages.push(viewPercent)
    else if AdJS.isViewed &&  (viewPercent < 50 || !$sf.ext.winHasFocus())
      unviewedTicks++
    else
      unviewedTicks = viewedTicks = 0
      viewedPercentages = []
    if viewedTicks == VIEWED_STRIKE
      AdJS.view() unless AdJS.isViewed
      AdJS.isViewed=true
    if unviewedTicks == VIEWED_STRIKE
      AdJS.unview() unless AdJS.isunViewed
      AdJS.isunViewed = true
      clearInterval(isViewedInterval)
    maxViewPercentage = viewPercent if viewPercent > maxViewPercentage
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

  $sf.lib.lang.mix(AdJS,events)

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
    $sf.ext.click()

  AdJS.view  ->
    $sf.ext.viewed()

  AdJS.unview ->
    $sf.ext.unviewed()

  AdJS.load ->
    registerForEvents()

  AdJS.load ->
    isViewedInterval = setInterval(updateIsViewed,100)

  AdJS.load ->
    AdJS.loadChain = utils.countFrames(window)
    request.set(load_chain:AdJS.loadChain)

  AdJS.request ->
    AdJS.requestTime = utils.now()
    geoInfo = $sf.ext.geom()
    request.set
      requested:true
      requestedAt:utils.now()
      req_t:utils.now() - startTicks
      req_view_pct: $sf.ext.inViewPercentage?()
      slot_x: geoInfo.self.l
      slot_y: geoInfo.self.t
      slot_w:geoInfo.self.w
      slot_h:geoInfo.self.h
      screen_w:window.screen.width
      screen_h:window.screen.height
      vp_x:geoInfo.win.l
      vp_y:geoInfo.win.t
      vp_w:geoInfo.win.w
      vp_h:geoInfo.win.h





  AdJS.load ->
    AdJS.loadTime = utils.now()
    console.log("loooooaddeddddd")
    sfDom.attach window,"unload",->
      $ad.unload()
    request.set
      loaded:true
      loadedAt:utils.now()
      load_t:utils.now() - startTicks



  AdJS.view ->
    AdJS.viewTime = utils.now()
    request.set
      viewed:true
      viewedAt:utils.now()
      view_t: utils.now() - startTicks
      view_meas:true #todo change this to start of request - although alls hould be measurable with js
      view_pct: utils.reduce(viewedPercentages,((memo,num)-> memo + num),0)/viewedPercentages.length
      view_pct_max: maxViewPercentage






  AdJS.engage ->
    AdJS.engageTime = utils.now()
    request.set
      engaged:true
      view_eng:true
      engagedAt:utils.now()

  AdJS.click ->
    AdJS.clickTime = utils.now()
    request.set
      clicked:true
      clickedAt:utils.now()
      clk_t: utils.now() - startTicks

  AdJS.unview ->
    AdJS.unviewTime = utils.now()
    request.set
      unviewed:true
      unviewedAt:utils.now()
      view_dur: utils.now() - AdJS.viewedAt
      view_pct_max: maxViewPercentage

  AdJS.unload ->
    AdJS.unloadTime = utils.now()
    request.set
      unloaded:true
      unloadedAt:utils.now()
      unl_t: utils.now() - startTicks

  $sf.ext.render(false)
  didShow = not $sf.lib.lang.cbool($sf.ext.meta("inview","extended"))
  referrerLevel = $sf.ext.meta("referrer","extended") or "all"
  host = $sf.ext.meta("host","extended")
  $sf.ext.deleteMeta("host","extended")
  location = $sf.ext.meta("location","extended")
  $sf.ext.deleteMeta("location","extended")
  $ad.slotId = $sf.ext.meta("slot_id","extended")
  $ad.count =  $sf.ext.meta("load_n","extended")
  request.set
    slot_id:  $sf.ext.meta("slot_id","extended")
    load_n: $sf.ext.meta("load_n","extended"),
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