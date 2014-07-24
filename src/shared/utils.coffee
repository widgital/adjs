window.JSON or= require 'json'
reqwest = require 'reqwest'
window.JSON or= require 'json'

module.exports = do ($sf)->
  #Commonly used utilities throughout the application
  #Also a few functions that proxy built in safeframe functions
  reqId = 0
  #uses reqwest - there is a bug in reqwest come up with our own jsonp callback. PR pending
  sendRequest = (options)->
    reqId++
    options.jsonpCallbackName = "adjs_#{now()}_#{reqId}"  if options.type=="jsonp"
    reqwest options
  #takes a query string and returns a js obj
  fromQuery = (query="",delim="&")->
    params = {}
    for item in query.split(delim)
      [key,value] = item.split("=")
      params[key] = decodeURIComponent(value)
    params
  #returns a string from a javacsript object representing a query string - uses reqwest
  toQuery = (attributes)->
    reqwest.toQueryString(attributes)

  #attempts to turn a string into a number if it fails returns 0
  toNumber = (val)->
    $sf?.lib.lang.cnum(val,0)

  # returns the current unix time could just do (+ new Date())
  now = ()->
    (new Date()).getTime()

  # shim for Object.defineproperty
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
  #counts number of child frames
  countFrames = (win)->
    count = win.frames.length
    for frame in win.frames
      count += countFrames(frame) unless  frame == win
    count
  # gets the current frames position
  getFramePosition = (win)->
    count = 0
    count = 1 + getFramePosition(win.parent) if win.parent != win.top
    count

  # taken from underscore
  nativeReduce = Array::reduce
  reduceError = 'Reduce of empty array with no initial value';
  #reduce function taken from underscore
  reduce = (obj, iterator, memo) ->
    initial = arguments.length > 2
    obj = []  unless obj?
    if nativeReduce and obj.reduce is nativeReduce
      return (if initial then obj.reduce(iterator, memo) else obj.reduce(iterator))
    for value,index in obj
      do (value, index, obj) ->
        unless initial
          memo = value
          initial = true
        else
          memo = iterator.call(@, memo, value, index, obj)
        return

    throw new TypeError(reduceError)  unless initial
    memo
  #returns an objects keys
  keys = (obj)->
    $sf?.lib.lang.keys(obj)

  #searches the top window for a controller
  #retries in case it hasn't been loaded yet
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

  #makes the first characture uppercase of a given string
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