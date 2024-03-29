#[Base](./base.html)
Base = require './base'
#[Config](./config.html)
config = require './config'


module.exports = do (window)->
  # The object representing the ad request
  class AdRequest extends Base
    constructor:(serializedParams)->
      super
      if serializedParams
        @deserialize(serializedParams)
      else
        @set
          url:window.document.location.href
          ref:window.document.referrer
          v_js:config.version
        ,silent:true
    serializedAttributes:()->
      outAttrs = {}
      for k,v of @attributes
        outAttrs[k] = v
      outAttrs.url = encodeURIComponent(outAttrs.url)
      outAttrs.ref = encodeURIComponent(outAttrs.ref)
      outAttrs
    deserialize:(params)->
      super(params)
      @set
        url:decodeURIComponent(@attributes.url)
        ref:decodeURIComponent(@attributes.ref)
      ,silent:true
    path:"/ad"
    constantFields:[
      "site_user_id"
      "page_id"
      "visit_id"
      "ad_id"
    ]



  return AdRequest