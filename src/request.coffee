Base = require './shared/base'
uuid = require 'node-uuid'


module.exports = do (window)->
  class Request extends Base
    constructor:(@clientId,@sessionId)->
      super
    path:"/event"
    constantFields:[
      "site_user_id",
      "page_id",
      "visit_id",
      "url",
      "req_id"
    ]


  return Request