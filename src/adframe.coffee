$sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
#[Utils](./utils.html)
utils = require('./shared/utils')
#[Config](./config.html)
config = require './shared/config'
#[AdRequest](./ad_request.html)
AdRequest = require './shared/ad_request'
#[advertiser](./advertiser.html)
advertiser = require './shared/advertiser'

#this is a specific safeframe that the ad generates
#its purpose is to communicate via javascript with all other frames on the adjs.net domain


do ($sf,window)->
  Ad = {}
  referrer = document.referrer
  adRequest = null

  document.domain = config.domain
  #define a set of unchangeable properties
  #this will be breakable in older browsers
  utils.defineProperty Ad,"isController",
    writeable:false
    value:false
    configurable:false
  utils.defineProperty window,"$ad",
    writeable: false
    value: Ad
    configurable: false
  referrer = document.referrer
  #pull in ad information
  setSessionInfo = (params)->
    adRequest.deserialize(params)

  onUpdate = (status,data)->

  #find the parent safeframe if it exists
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
  #call the work function will act differently if we are a safeframe
  advertiser.work(adRequest,parentWindow)







