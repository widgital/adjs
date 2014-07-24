endpoint = require './endpoint'
utils = require './utils'

module.exports = do (window)->
  # shared advertiser function to create the key and find controller if it exists
  # this will work both in a standalone ad or in a ad.js safeframe
  # todo: change the name of work
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