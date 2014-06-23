reqwest = require 'reqwest'
config = require './config'

module.exports = do ()->
  prefix = config.api
  pendingRequests = {}
  sendingRequests = {}

  send = (url, data, success, error)->
    reqwest
      url: url
      type: 'jsonp'
      data: data
      success: success
      error: error

  page: (session)->

    success = (resp)->
      session.set(resp,silent:true)

    error = (err)->
      console.log "ERROR:" + err

    # map the keys used in cookies to more descriptive keys that are used by the api
    subst = {id: page_id}
    obj = {}; obj[subst[k]] = v for k, v of session.attributes
    console.log(JSON.stringify(obj, null, '\t'))

    # send page request to the API
    send prefix + '/page', session.attributes, success, error

  event: (request,cb,isAttempt)->

    success = (resp)->
      request.set(resp,silent:true)
      cb?(resp)
      delete sendingRequests[request.id]
    error = (err)->
      console.log "ERROR:" + err
    if !sendingRequests[request.id]
      delete pendingRequests[request.id]
      sendingRequests[request.id] = true
      send prefix + '/event', request.attributes, success, error
    else if !pendingRequests[request.id] or isAttempt
      pendingRequests[request.id]
      setTimeout( =>
        event(request,cb,true)
      ,500)