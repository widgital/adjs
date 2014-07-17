$sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
utils = require('./shared/utils')
config = require './shared/config'
AdRequest = require './shared/ad_request'
advertiser = require './shared/advertiser'


do ($sf,window)->
  Ad = {}
  referrer = document.referrer
  adRequest = null

  document.domain = config.domain

  utils.defineProperty Ad,"isController",
    writeable:false
    value:false
    configurable:false
  utils.defineProperty window,"$ad",
    writeable: false
    value: Ad
    configurable: false
  referrer = document.referrer
  setSessionInfo = (params)->
    adRequest.deserialize(params)

  onUpdate = (status,data)->
    switch status
      when "cookie-update" then setSessionInfo(unescape(data.value))
  findParent = (win,myDepth=0)->
    if win.parent == win.top
      try
        if win.$ad
          [win,myDepth]
      catch
        null
    else
      findParent(win.parent,myDepth+1)


  $sf.ext.render(true,"")
  $sf.ext.register 0,0,onUpdate

  adRequest = new AdRequest($sf.ext.meta("page","extended"))
  [parentWindow,myDepth] = findParent(window)
  adRequest.set(depth_position:myDepth)
  advertiser.work(adRequest,parentWindow)







