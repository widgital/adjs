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
    endpoint.send(session)
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
    session.set(utils.fromQuery params)

  try
    utils.defineProperty document,"referrer",
      get:->
        return ""
  catch e
    #do nothing
  onUpdate = (status,data)->
    switch status
      when "cookie-update" then setSessionInfo(unescape(data.value))

  $sf.ext.render(true)

  setSessionInfo $sf.ext.meta("session","extended"),silent:true

  $sf.ext.register 0,0,onUpdate









