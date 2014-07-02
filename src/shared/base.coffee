uuid = require 'node-uuid'
module.exports = do ()->
  #base class to handle object level events... not sure how to use this yet

  class Base

    constructor:()->
      @id = uuid.v4()
      @attributes ||= {}
      @_events = []

    set:(attrs,options={})->
      throw "attrs must be an object" unless typeof attrs == "object"
      changed = false
      changedAttributes = []
      for k,v of attrs
        if @attributes[k] != v
          changedAttributes.push k
        @attributes[k] = v
      if !options.silent && changedAttributes.length>0
        f.apply(@,[@,changedAttributes]) for f in @_events
    change:(f)->
      if f and typeof f == "function"
        @_events.push f
      else unless f
        f.apply(@,arguments) for f in @_events


