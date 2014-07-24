#the publisher script sits in the ad or on the publishers page
#this should be renamed, but its the only script an outside party needs to know about

inPubframe = false

#check to see if safeframe already exists if we aren't top. Are we in a publisher safeframe?
if window.parent==window.top && window !=window.top && window["$sf"]
  sf = $sf
  inPubframe = true
else
  sf =  require('../node_modules/safeframe/lib/js/host/host')(true) unless window["$sf"]



#[Slot](./slot.html) the slot object becomes the base of what is accessible by the external programmer i.e. $ad("adid")
AdJS = require './publisher/slot'
#[Config](./config.html)
config = require './shared/config'
#[Utils](./utils.html)
utils  =require './shared/utils'
#[AdRequest](./ad_request.html)
AdRequest = require './shared/ad_request'
#[Advertiser](./advertiser.html)
advertiser = require './shared/advertiser'

##advertiser code path
do (window)->
  # initialize session
  sessionObj =  new AdRequest()

  startTicks = utils.now()
  pageLoadMs = 0
  pageDuration = 0
  #all 3 frames have a different url
  adframeUrl = config.ad_url
  sfDom =  $sf.lib.dom
  sfDom.attach "beforeunload",->
    pageDuration =  utils.now()-startTicks
    true


  #initialize the safeframe configuration

  initSafeFrame =  ->
    $sf.host.Config
      renderFile: adframeUrl
      positions:{}
      onStartPosRender: ->
      onFailure: ->
      onAdLoad: (id)->
        AdJS(id).load()
      onBeforePosMsg: ()->
      onPosMsg: (id,msg,content)->
        AdJS(id).handleMessage(msg,content)
  # renders the ad if we are downstream in the ad creative
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


  #renders the publishers ad slots or does the creative ad work
  #iterates through data-adjs divs see description of values in slot
  AdJS.render = (cb)->
    adJsScript = (s for s in document.getElementsByTagName("script") when sfDom.attr(s,"data-adjs"))[0]
    clientId = sfDom.attr(adJsScript,"data-client-id")
    sessionObj.set  client_id:clientId
    initSafeFrame()
    renderAd()

  #render ad.js ad slots
  if inPubframe
    sessionObj.set(depth_position:0)
    advertiser.work(sessionObj,window)
  else
    do ->
      AdJS.render()


  #add module.exports for this...
  window.$ad = AdJS unless inPubframe
  AdJS