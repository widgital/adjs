$sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
utils = require('./shared/utils')
endpoint = require './controller/endpoint'
Session = require './shared/session'
config = require './shared/config'


do ($sf,window)->
  Controller = {}
  referrer = document.referrer
  session = new Session()
  document.domain = config.domain
  session.change ->
#    endpoint.send(session)
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
  referrer = document.referrer
  setSessionInfo = (params)->
    session.set(params)

  try
    utils.defineProperty document,"referrer",
      get:->
        return ""
  catch e
    #do nothing
  onUpdate = ->
    switch status
      when "cookie-update" then setSessionInfo(unescape(data.value))
#  delete window.$sf
#  utils.defineProperty window,"$sf",
#    writeable: false
#    value: null
#    configurable: false
  $sf.ext.render(true)

  setSessionInfo $sf.ext.meta("session","extended"),silent:true

  $sf.ext.register 0,0,onUpdate









