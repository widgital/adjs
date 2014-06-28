config = require '../shared/config'
stream = require '../shared/stream'

module.exports = (AdJS,request,window)->

  #initial request setting
  request.change ->
    stream.event request

  request.set
    load_pos:utils.getFramePosition(window)
    v_js:config.version
    req_url_blind: true #todo this will not always be true
    tz:(new Date()).getTimezoneOffset()

  AdJS.load ->
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