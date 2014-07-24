$sf = require('../node_modules/safeframe/lib/js/ext/ext')(true)
#[Utils](./utils.html)
utils = require('./shared/utils')
#[Endpoint](./endpoint.html)
endpoint = require './shared/endpoint'
#[Page](./page.html)
Page = require './shared/page'
#[Config](./config.html)
config = require './shared/config'

#the controller exists to do manage all communication with the server
#it should exist at the api level and can probably take data as part of the call depending on performance


do ($sf,window)->
  Controller = {}
  referrer = document.referrer
  page = null
  document.domain = config.domain
  #a list of all active requests, need a facility for killing them as well...
  requests = {}
  #lock down isController
  utils.defineProperty Controller,"isController",
    writeable:false
    value:true
    configurable:false
  #lock down send function this is to prevent outsiders who inject code into frame from overwriteing this on most browsers
  utils.defineProperty Controller,"send",
    writeable:false
    value:(request)->
      requests[request.id] = request
      request.set(page.attributes,silent:true)
      endpoint.send(request)
    configurable:false
  #lock down combine
  utils.defineProperty Controller,"combine",
    writeable:false
    value:(request,adRequest)->
      endpoint.combine(request,adRequest)
    configurable:false
  #lock down ad
  utils.defineProperty window,"$ad",
    writeable: false
    value: Controller
    configurable: false
  referrer = document.referrer
  #set page info
  setSessionInfo = (params)->
    page.deserialize(params)


  try
    utils.defineProperty document,"referrer",
      get:->
        return ""
  catch e

  #do nothing
  onUpdate = (status,data)->

  #no content in this safeframe
  $sf.ext.render(true,"")
  $sf.ext.register 0,0,onUpdate
  page = new Page($sf.ext.meta("page","extended"))
  page.change ->
    endpoint.send(page)
  # todo refactor most of this to iframe itself not a safeframe ever
  #todo remove window references to

  endpoint.send page,()->
    #update all requests with page_id, site_user_id, visit_id, etc...
    r.set(page.attributes,silent:true) for k,r in requests











