#the publisher script sits in the ad or on the publishers page
#this should be renamed, but its the only script an outside party needs to know about



sf =  require('safeframe') unless window["$sf"]


#[Engagement](./engagement.html)
engagement = require './shared/engagement'
#[Page](./page.html)
Page = require './shared/page'

#[Slot](./slot.html) the slot object becomes the base of what is accessible by the external programmer i.e. $ad("adid")
AdJS = require './publisher/slot'
#[Config](./config.html)
config = require './shared/config'
#[Utils](./utils.html)
utils  =require './shared/utils'
#[AdRequest](./ad_request.html)
AdRequest = require './shared/ad_request'

##advertiser code path
do (window)->
  # initialize session
  sessionObj =  new Page()


  startTicks = utils.now()
  pageLoadMs = 0
  pageDuration = 0
  #all 3 frames have a different url
  safeframeUrl = config.cdn_url
  controllerUrl = config.controller_url
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
      #todo: this should be moved to when the body exists not to when page renders
      # - controller is first thing that should exists
      renderController()
      divs = (div for div in document.getElementsByTagName("div"))
      for d in divs when sfDom.attr(d,"data-adjs")
        do (d)->
          AdJS.create(d,sessionObj)
      cb?()

  #initialize the safeframe configuration

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
  #creates an invisible safeframe with no events
  #this is used for all upstream communication and eventually bulk sending of data
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
      page: sessionObj.serializedAttributes()
      pageReferrer: document.referrer
      ignoreEvents:  true



  #renders the publishers ad slots or does the creative ad work
  #iterates through data-adjs divs see description of values in slot
  AdJS.render = (cb)->
    adJsScript = (s for s in document.getElementsByTagName("script") when sfDom.attr(s,"data-adjs"))[0]
    clientId = sfDom.attr(adJsScript,"data-client-id")
    sessionObj.set  client_id:clientId
    initSafeFrame()
    doRender(cb)
  #session events
  #handles global engagement
  engagement.onEngagement ->
    for _,ad of AdJS.slots
      if ad.currentlyInview() && !ad.engaged
        ad.engage()
  #render ad.js ad slots
  do ->
    AdJS.render()


  #add module.exports for this...
  window.$ad = AdJS
  AdJS