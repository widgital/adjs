Base = require './shared/base'
uuid = require 'node-uuid'


module.exports = do (window)->
  class Request extends Base
    constructor:(@clientId,@sessionId)->
      super
      @id = uuid.v4()
    path:"/event"


  return Request