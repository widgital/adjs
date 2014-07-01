#todo make this send multiple api and queue and listener need to be updated for this to happen
config = require '../shared/config'
utils = require '../shared/utils'


module.exports = do ($sf)->
  prefix = config.api

  pendingRequests = {}
  sendingRequests = {}
  RETRY_TIMEOUT = 100
  isTimeout = false
  timeoutValue = null
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
  send = (obj,cb)->
    pendingRequests[obj.id] = [obj,cb]
    postData()
  success = (obj,resp,cb)->
    obj.set(resp,silent:true)
    delete sendingRequests[obj.id]
    cb?(obj)
  error = (obj,err,cb)->

  sendData = (params,obj,cb)->
    requestParams =
      data:params
      success:(resp)->success(obj,resp,cb)
      error:(err)->error(obj,err,cb)
    if prefix.indexOf(document.location.hostname)>=0
      requestParams.method = "post"
      requestParams.url = obj.path
    else
      requestParams.type="jsonp"
      requestParams.url = prefix + obj.path
    utils.sendRequest requestParams



  postData = ()->
    for id,[obj,cb] of pendingRequests
      unless sendingRequests[obj.id] #when not sendingRequests[obj.id] compiling to !(!(sendingRequests[obj.id]))
        delete pendingRequests[id]
        params = {}
        params[mapping[k] or k] = v for k,v of obj.attributes
        sendingRequests[obj.id] = obj
        sendData(params,obj,cb)
    if $sf.lib.lang.keys(pendingRequests).length>0 && !isTimeout
      isTimeout = true
      timeoutValue = setTimeout(->
        isTimeout=false
        postData()
      ,RETRY_TIMEOUT)

  endpoint = send:send
  if process.env.ENV == "test"
    endpoint.postData = postData
    endpoint.sendData = sendData
    endpoint.success = success
    endpoint.error = error
    endpoint.sendingRequests = sendingRequests
    endpoint.pendingRequests = pendingRequests
    endpoint.clear = ->
      isTimeout = false
      sendingRequests = {}
      pendingRequests = {}
      endpoint.sendingRequests = sendingRequests
      endpoint.pendingRequests = pendingRequests
      clearTimeout(timeoutValue)

  return endpoint