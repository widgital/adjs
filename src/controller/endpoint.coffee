config = require '../shared/config'
reqwest = require 'reqwest'
module.exports = ()->
  prefix = config.api
  pendingRequests = {}
  sendingRequests = {}
  mapping =
    id: "user_id"
    p: "site_page_vw"
    a: "site_ad_req"
    av: "site_ad_vw"
    ac: "site_ad_clk"
    ae: "site_ad_vw_eng"
    v: "site_vis"
    vp: "vis_page_vw"
    va: "vis_ad_req"
    vav: "vis_ad_vw"
    vae: "vis_ad_vw_eng"
    vac: "vis_ad_clk"
  send = (obj)->
    pendingRequests[obj.id] = obj
    postData()
  success = (obj,cb)->
  error = (obj,cb)->

  postData = ->
    for id,obj of pendingRequests when not sendingRequests[obj.id]
      delete pendingRequests[id]
      params = {}
      params[mapping[k] or k] = v for k,v of obj.attributes
      send prefix + obj.path,params,

#      sendingRequests[request.id] = true
#      params = {}
#      params[mapping[k] or k] = v for k,v of request.attributes
#      send prefix + '/event', params, success, error
#    else if !pendingRequests[request.id] or isAttempt
#      pendingRequests[request.id]
#      setTimeout( =>
#        @event(request,cb,true)
#      ,500)










  endpoint = send:send
  if process.env.ENV == "test"
    endpoint.postData = postData






#
#  send = (url, data, success, error)->
#    reqwest
#      url: url
#      type: 'jsonp'
#      data: data
#      success: success
#      error: error
#
#  page: (session)->
#
#    success = (resp)->
#      session.set(resp)
#
#    error = (err)->
#      console.log "ERROR:" + err
#
#    # map the keys used in cookies to more descriptive keys that are used by the api
#    #    subst = {}
#    #    obj = {};
#    #    obj[subst[k]] = v for k, v of session.attributes when subst[k]
#    send prefix + '/page', session.attributes, success, error
#
#  event: (request,cb,isAttempt)->
#
#    success = (resp)->
#      request.set(resp,silent:true)
#      cb?(resp)
#      delete sendingRequests[request.id]
#    error = (err)->
#      console.log "ERROR:" + err
#    if !sendingRequests[request.id]
#      delete pendingRequests[request.id]
#      sendingRequests[request.id] = true
#      params = {}
#      params[mapping[k] or k] = v for k,v of request.attributes
#      send prefix + '/event', params, success, error
#    else if !pendingRequests[request.id] or isAttempt
#      pendingRequests[request.id]
#      setTimeout( =>
#        @event(request,cb,true)
#      ,500)
