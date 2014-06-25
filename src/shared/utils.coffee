window.reqwest or= require 'reqwest'
window.JSON or= require 'json'

module.exports = do ($sf,window)->

  reqwest = window.reqwest

  sendRequest = (url,options)->
    reqwest
      url: url
      type: 'jsonp'
      success: options.success
      error: options.error
      data: options.data

  fromQuery = (query="",delim="&")->
    params = {}
    for item in query.split(delim)
      [key,value] = item.split("=")
      params[key] = decodeURIComponent(value)
    params

  toQuery = (attributes)->
    reqwest.toQueryString(attributes)

  toNumber = (val)->
    $sf?.lib.lang.cnum(val,0)

  now = ()->
    (new Date()).getTime()

  defineProperty = (obj,prop,descriptor)->
    try
      if "defineProperty" of Object
        Object.defineProperty(obj,prop,descriptor)
      else if "__defineGetter__" of obj
        if descriptor.value
          obj.__defineGetter__(prop,-> descriptor.value)
          if descriptor.writable != false
            obj.__defineSetter__(prop,(val)->
              val[prop] = val
          )
        else
          obj.__defineGetter__(prop,descriptor.get) if descriptor.get?
          obj.__defineSetter__(prop,descriptor.set) if descriptor.set?
    catch e
      console.log(e)
      #

  countFrames = (win)->
    count = win.frames.length
    for frame in win.frames
      count += countFrames(frame) unless  frame == win
    count

  getReferrer = (win)->


    # get referrer from query string
    qs = object.fromQuerystring("referrer", window.location.href) or object.fromQuerystring("referer", window.location.href)
    return qs if qs

    # try to get the top referer - otherwise, move up the stack until we get something
    try
      referrer = window.top.document.referrer
    catch e
      w = window.parent
      do
        if w
        try
          referrer = w.document.referrer
        catch e2
          referrer = ''

    referrer = document.referrer if referrer is ''
    referrer


#
#	 * Cross-browser helper function to add event handler
#
object.addEventListener = (element, eventType, eventHandler, useCapture) ->
  if element.addEventListener
    element.addEventListener eventType, eventHandler, useCapture
    return true
  return element.attachEvent("on" + eventType, eventHandler)  if element.attachEvent
  element["on" + eventType] = eventHandler
  return





capitalizeString  = (string)->
    string.charAt(0).toUpperCase() + string.slice(1);

  sendRequest: sendRequest
  toQuery: toQuery
  fromQuery: fromQuery
  toNumber: toNumber
  now: now
  defineProperty: defineProperty
  countFrames: countFrames
  capitalizeString: capitalizeString