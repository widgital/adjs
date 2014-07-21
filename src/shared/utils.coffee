window.JSON or= require 'json'
reqwest = require 'reqwest'
window.JSON or= require 'json'

module.exports = do ($sf)->
  reqId = 0

  sendRequest = (options)->
    reqId++
    options.jsonpCallbackName = "adjs_#{now()}_#{reqId}"  if options.type=="jsonp"
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

  findController = (cb,retry=3)->
    controller = null
    for frame in window.top.frames
      try
        if frame.$ad?.isController
          controller = frame.$ad
          break
      catch
    if controller
      cb(controller)
    else
      setTimeout((->findController(cb,retry-1)),100) unless retry<0

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
  findController: findController