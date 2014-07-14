uuid = require 'node-uuid'
utils = require './utils'
module.exports = do ()->
  #base class to handle object level events... not sure how to use this yet

  class Base

    constructor:()->
      @id = uuid.v4()
      @attributes ||= {}
      @_events = []
      @_dirty = {}

    set:(attrs,options={})->
      throw "attrs must be an object" unless typeof attrs == "object"
      changed = false
      changedAttributes = []
      for k,v of attrs
        if @attributes[k] != v
          changedAttributes.push k
          @_dirty[k]=v
          @attributes[k] = v
      if !options.silent && changedAttributes.length>0
        f.apply(@,[@,changedAttributes]) for f in @_events
    change:(f)->
      if f and typeof f == "function"
        @_events.push f
      else unless f
        f.apply(@,arguments) for f in @_events
    #not sure about this feel like this functionality should be encapsulated but would need to encapsulate syncing...
    _cleanDirty:()->
      @_dirty = {}
    changedFields:()->
      params = {}
      for k,v of @_dirty
        params[k] = v
      for field in @constantFields
        params[field] = @attributes[field] if @attributes[field]
      @_cleanDirty()
      params
    serialize:()->
      utils.toQuery(@attributes)
    deserialize:(str)->
      @set(utils.fromQuery(str),silent:true)



