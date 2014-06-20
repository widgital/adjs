window.JSON or= require 'json'
utils = require './shared/utils'
Base = require './shared/base'


module.exports = do (window)->

  class Request extends Base
    REQ_INTERVAL = 50
    constructor:(clientId,sessionId)->
      super
    sendRequest:()->
      if not @requestInProcess
        @requestInProcess = true
        clearTimeout(@timeoutId)
        @timeoutId = null
        utils.sendRequest "http://127.0.0.1/test",
          data:@attributes
          success:(data)->
            @requestInProcess = false
            @set(data,silent:true)
      else
        unless @timeoutId
          @waiting =true
          @timeoutId = setTimeout =>
            clearTimeout(@timeoutId)
            @timeoutId = null
            @sendRequest()

  return Request