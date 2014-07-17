$sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
utils = require('./shared/utils')
endpoint = require './shared/endpoint'
Page = require './shared/page'
config = require './shared/config'


do ($sf,window)->
  Controller = {}
  referrer = document.referrer
  page = null
  document.domain = config.domain
  requests = {}

  utils.defineProperty Controller,"isController",
    writeable:false
    value:true
    configurable:false
  utils.defineProperty Controller,"send",

    writeable:false
    value:(request)->
      requests[request.id] = request
      request.set(page.attributes,silent:true)
      endpoint.send(request)
    configurable:false
  utils.defineProperty Controller,"combine",
    writeable:false
    value:(request,adRequest)->
      endpoint.combine(request,adRequest)
    configurable:false

  utils.defineProperty window,"$ad",
    writeable: false
    value: Controller
    configurable: false
  referrer = document.referrer
  setSessionInfo = (params)->
    page.deserialize(params)


  try
    utils.defineProperty document,"referrer",
      get:->
        return ""
  catch e
    #do nothing
  onUpdate = (status,data)->
    switch status
      when "cookie-update" then setSessionInfo(unescape(data.value))

  $sf.ext.render(true,"")
  $sf.ext.register 0,0,onUpdate
  page = new Page($sf.ext.meta("page","extended"))
  page.change ->
    endpoint.send(page)
  # todo refactor most of this to iframe itself not a safeframe ever
  endpoint.send page,()->
    r.set(page.attributes,silent:true) for k,r in requests











