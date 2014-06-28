utils = require './shared/utils'
endpoint = require './controller/endpoint'

do (window)->
  Controller = {}

  utils.defineProperty Controller,"isController",
    writeable:false
    value:true
    configurable:false
  utils.defineProperty Controller,"send",
    writeable:false
    value: endpoint.send
    configurable:false
  utils.defineProperty window,"$ad",
    writeable: false
    value: Controller
    configurable: false




