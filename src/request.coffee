Base = require './shared/base'
uuid = require 'node-uuid'


module.exports = do (window)->
  class Request extends Base
    constructor:(@clientId,@sessionId)->
      super
      @id = uuid.v4()
    path:"/event"
    constantFields:[
      "site_user_id",
      "page_id",
      "visit_id",
      "full_url",
      "req_id"
    ]


  return Request