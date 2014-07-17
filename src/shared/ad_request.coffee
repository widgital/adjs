Base = require './base'


module.exports = do (window)->
  class AdRequest extends Base
    constructor:(serializedParams)->
      super
      if serializedParams
        @deserialize(serializedParams)
      else
        @set
          full_url:window.document.location.href
          referrer:window.document.referrer
        ,silent:true
    path:"/ad"
    constantFields:[
      "site_user_id"
      "page_id"
      "visit_id"
      "ad_id"
    ]



  return AdRequest