window.JSON or= require 'json'
reqwest = require 'reqwest'
window.JSON or= require 'json'

module.exports = do ($sf)->

  sendRequest = (options)->
    reqwest options

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
      else
        if descriptor.value
          obj[prop] = descriptor.value
    catch e
      console.log(e)
      #

  countFrames = (win)->
    count = win.frames.length
    for frame in win.frames
      count += countFrames(frame) unless  frame == win
    count
  getFramePosition = (win)->
    count = 0
    count = 1 + getFramePosition(win.parent) if win.parent != win.top
    count

  # taken from underscore
  nativeReduce = Array::reduce
  reduceError = 'Reduce of empty array with no initial value';
  reduce = (obj, iterator, memo, context) ->
    initial = arguments.length > 2
    obj = []  unless obj?
    if nativeReduce and obj.reduce is nativeReduce
      iterator = _.bind(iterator, context)  if context
      return (if initial then obj.reduce(iterator, memo) else obj.reduce(iterator))
    for value,index in obj
      do (value, index, obj) ->
        unless initial
          memo = value
          initial = true
        else
          memo = iterator.call(context, memo, value, index, obj)
        return

    throw new TypeError(reduceError)  unless initial
    memo

  keys = (obj)->
    $sf?.lib.lang.keys(obj)


#  getReferrer = (win,referrer=null)
#    if win == window.top
#

#  getReferrer = (win)->
#
#
#    # get referrer from query string
#    qs = object.fromQuerystring("referrer", window.location.href) or object.fromQuerystring("referer", window.location.href)
#    return qs if qs
#
#    # try to get the top referer - otherwise, move up the stack until we get something
#    try
#      referrer = window.top.document.referrer
#    catch e
#      w = window.parent
#      do
#        if w
#        try
#          referrer = w.document.referrer
#        catch e2
#          referrer = ''
#
#    referrer = document.referrer if referrer is ''
#    referrer


#
#	 * Cross-browser helper function to add event handler
##
#object.addEventListener = (element, eventType, eventHandler, useCapture) ->
#  if element.addEventListener
#    element.addEventListener eventType, eventHandler, useCapture
#    return true
#  return element.attachEvent("on" + eventType, eventHandler)  if element.attachEvent
#  element["on" + eventType] = eventHandler
#  return





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
  keys: keys
  getFramePosition: getFramePosition
  reduce: reduce