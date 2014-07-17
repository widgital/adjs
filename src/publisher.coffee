inPubframe = false
if window.parent==window.top && window !=window.top && window["$sf"]
  sf = $sf
  inPubFrame = true
else
  sf =  require('../node_modules/safeframe/lib/js/host/host')(true) unless window["$sf"]



engagement = require './shared/engagement'
Page = require './shared/page'
AdJS = require './publisher/slot'
config = require './shared/config'
utils  =require './shared/utils'
AdRequest = require './shared/ad_request'
advertiser = require './shared/advertiser'

##advertiser code path

##

do (window)->
  # initialize session
  sessionObj = null
  if window == window.top
    sessionObj = new Page()
  else
    sessionObj = new AdRequest()
  startTicks = utils.now()
  pageLoadMs = 0
  pageDuration = 0
  safeframeUrl = config.cdn_url
  controllerUrl = config.controller_url
  adframeUrl = config.ad_url
  sfDom =  $sf.lib.dom
  sfDom.attach "beforeunload",->
    pageDuration =  utils.now()-startTicks
    true

  doRender = (cb)->
    sfPositions  = {}
    if !sfDom.ready()
      sfDom.wait ->
        pageLoadMs = (utils.now() - startTicks)
        doRender.apply null, args
        args = null
      return
    else
      renderController()
      divs = (div for div in document.getElementsByTagName("div"))
      for d in divs when sfDom.attr(d,"data-adjs")
        do (d)->
          AdJS.create(d,sessionObj)
      cb?()

  initSafeFrame =  ->
    $sf.host.Config
      renderFile:if window == window.top then safeframeUrl else adframeUrl
      positions:{}
      onStartPosRender: ->
      onFailure: ->
      onAdLoad: (id)->
        AdJS(id).load()
      onBeforePosMsg: ()->
      onPosMsg: (id,msg,content)->
        AdJS(id).handleMessage(msg,content)

  renderController = ->
    div = document.createElement("div")
    parent = document.createElement("div")
    parent.appendChild(div)
    parent.style.display= "none"
#    div.style.visibility="hidden"
    div.id= sf.lib.lang.guid "controller"
    document.body.appendChild(parent)
    AdJS("controller").create div,'',
      width:10
      height:10
      supports:["write-cookie","read-cookie"]
      renderFile: controllerUrl
      page: sessionObj.serialize()
      pageReferrer: document.referrer
      ignoreEvents:  true
  renderAd = ->
    div = document.createElement("div")
    parent = document.createElement("div")
    parent.appendChild(div)
    parent.style.display= "none"
    #    div.style.visibility="hidden"
    div.id= sf.lib.lang.guid "creative"
    document.body.appendChild(parent)
    AdJS("creative").create div,'',
      width:10
      height:10
      renderFile: adframeUrl
      page: sessionObj.serialize()
      pageReferrer: document.referrer
      ignoreEvents:  true



  AdJS.render = (cb)->
    adJsScript = (s for s in document.getElementsByTagName("script") when sfDom.attr(s,"data-adjs"))[0]
    clientId = sfDom.attr(adJsScript,"data-client-id")
    sessionObj.set  client_id:clientId
    initSafeFrame() unless inPubFrame
    if window.top == window
      doRender()
    else if inPubFrame
      sessionObj.set(depth_position:0)
      advertiser.work(sessionObj,window)
    else
      renderAd()
  #session events

  engagement.onEngagement ->
    for _,ad of AdJS.slots
      if ad.currentlyInview() && !ad.engaged
        ad.engage()

  do ->
    AdJS.render()


  #add module.exports for this...
  window.$ad = AdJS unless inPubframe
  AdJS