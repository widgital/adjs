endpoint = require './endpoint'
utils = require './utils'

module.exports = do (window)->
  work = (adRequest,pubFrame)->
    controller=  null
    utils.defineProperty window,"getDetails",
      writeable:false
      value:()->
        return adRequest
      configurable:false

    endpoint.send adRequest,->
      pubFrame.$ad.readAd(window)
      utils.findController (ctrl)->
        controller = ctrl
        adRequest.change ->
          controller.send(adRequest)


  work:work