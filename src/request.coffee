Base = require './shared/base'
uuid = require 'node-uuid'


module.exports = do (window)->

  class Request extends Base
    REQ_INTERVAL = 50
    path:"/event"
    constructor:(@clientId,@sessionId)->
      super
      @id = uuid.v4()


  return Request