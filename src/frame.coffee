currentName = window.name

$sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
#[Events](./event.html)
events = require('./shared/event')(["request","load","view","click","expanded","collapsed",
                                    "engage","unview","unload"])
#[Utils](./utils.html)
utils = require './shared/utils'
#[Request](./request.html)
Request = require './request'
#[Config](./config.html)
config = require './shared/config'

do ($sf,window)->

  document.domain = config.domain
  controller = null
  sfDom = $sf.lib.dom
  AdJS = {}
  #protect this frame from being a controller as arbitrary scripts can be injected
  #will make sense to inject a second domain with our scripts to fully control the controller domain
  utils.defineProperty AdJS,"isController",
    writable:false
    value:false
    configurable:false


  request = new Request()
  #set information that is immediately available about the ad load_pos should always be 1
  request.set
    load_pos:utils.getFramePosition(window)
    v_js:config.version
    req_url_blind: true #todo this will not always be true
    tz:(new Date()).getTimezoneOffset()
  #find the controller and send request when you get it
  utils.findController (ctrl)->
    controller = ctrl
    request.change ->
      controller.send(request)
    controller.send(request)

  #ticks before we decide the slot has been viewed
  VIEWED_STRIKE = 9
  #running tally of ticks
  viewedTicks = 0
  #similar to viewed ticks but for being out of view
  unviewedTicks = 0
  width= window.innerWidth
  height= window.innerHeight
  registered = false
  didShow = false
  requested =false
  #time of this script being loaded
  startTicks = utils.now()
  maxViewPercentage = 0
  viewedPercentages = []

  attributes = {}

  AdJS.setDimensions = (w,h)->
    width = w
    height = h
  #safeframe method for handling external events
  registerForEvents = ()->
    registered = true
    $sf.ext.register width,height,onUpdate

  #experimental method to override doc.refferer this does not work in any safari browser
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
  #manages updates from the publisher
  onUpdate = (status,data)->
    switch status
      when "expanded" then  ()-> AdJS.expanded()
      when "collapsed" then  ()-> AdJS.collapsed()
      when "geom-update" then showAd()
      when "engaged" then AdJS.engage()
      when "requested" then AdJS.request()  unless requested

  isViewedInterval =null
  #handle viewbality in an interval as the ticks go up to VIEWED_STRIKE
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

  #display the ad if viewability is required show it in view otherwise just show it
  showAd = (show)->
    if ($sf.ext.inViewPercentage?() > 5 && !didShow) or show
      clearInterval(showAdTimer) if showAdTimer
      startTime = utils.now()
      AdJS.request()
      $sf.ext.showAd null,->
        AdJS.load()
      didShow=true
    else unless showAdTimer || didShow
      showAdTimer = setInterval(forceNuke,50)
  #if its viewability only advertisement kill the frame and have publisher reload it once in view
  forceNuke = ()->
    if ($sf.ext.inViewPercentage?() > 5 && showAdTimer)
      clearInterval(showAdTimer)
      showAdTimer=null
      $sf.ext.reload()

  $sf.lib.lang.mix(AdJS,events)
  #override default events to pass specific values -not sure this is required anymore
  AdJS.on = (event,cb)->
    events.on.apply(@,[event,cb])

  #proxy functions so advertiser can call these methods from $ad.exand etc...
  AdJS.expand = (deltaXorDesc, deltaY, p)-> $sf.ext.expand(deltaXorDesc,deltaY,p)
  AdJS.collapse = -> $sf.ext.collapse()
  AdJS.cookie = (cookieName,cookieData)-> $sf.ext.cookie(coookieName,cookieData)
  AdJS.supports = (key)-> $sf.ext.supports(key)
  AdJS.sendMessage = (content)->
    setTimeout(->
      $sf.ext.message(encodeURIComponent(content))
    ,1)
  #handle click event in most cases this won't work
  #todo add this to ad script
  sfDom.attach(document.body,"mouseup",->
    AdJS.click()
    true
  )

  #Register events that send to the parent
  #the following events are available from the frame as an advertiser
  #
  #  event name | description
  #  -----------|--------------
  #  request | occurs when the ad is requested
  #  click | occurs when the ad is clicked
  #  load | occurs when the ad has been loaded
  #  view | Occurs when greater than 50% of the ad is in view for greater than 1 second
  #  unload | Occurs when the ad is removed
  #  engage | occurs when there is engagement and the view event has already fired
  #  unview | occurs when a viewed ad leaves view
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
  #set request specific data on request of the ad including geometry information
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




  #begin the timeline of events as they occur
  AdJS.load ->
    AdJS.loadTime = utils.now()
    sfDom.attach window,"unload",->
      AdJS.unload()
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
  #handle and set data from the parent
  didShow = not $sf.lib.lang.cbool($sf.ext.meta("inview","extended"))
  referrerLevel = $sf.ext.meta("referrer","extended") or "all"
  host = $sf.ext.meta("host","extended")
  $sf.ext.deleteMeta("host","extended")
  location = $sf.ext.meta("location","extended")
  $sf.ext.deleteMeta("location","extended")
  AdJS.slotId = $sf.ext.meta("slot_id","extended")
  AdJS.count =  $sf.ext.meta("load_n","extended")
  #set the data on the request as neccasary
  request.set
    slot_id:  $sf.ext.meta("slot_id","extended")
    load_n: $sf.ext.meta("load_n","extended"),
    page_url: location
    page_host: host
    {silent:true}
  #if referrer is hiddent redirect to self or show the page
  showPage = document.location.href == document.referrer or updateReferrer(referrerLevel)
  if showPage
    showAd(didShow)
  else
    window.name = currentName
    document.location = document.location
  #ad frame must be a child or equal in order to take it seriously
  confirmChild = (win,adFrame)->
    return true if win==adFrame
    return (childFrame for childFrame in win.frames when confirmChild(childFrame,adFrame)).length > 0

  #reads the ad
  readAd = (adFrame)->
    if confirmChild(window,adFrame)
      controller.combine(request,adFrame.getDetails())

  #lock down $ad
  utils.defineProperty window,"$ad",
    writable:false
    value:AdJS
    configurable:false
  utils.defineProperty AdJS,"readAd",
    writable:false
    value:readAd
    configurable:false

  AdJS