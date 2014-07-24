uuid = require 'node-uuid'
#[Utils](./utils.html)
utils = require './utils'
module.exports = do ()->
  #base class to handle objects - partially based off of backbone models
  class Base
    #create object all iherited class constructors should call super otherwise youll have a bad time
    constructor:()->
      #a unique identifier for the object
      @id = uuid.v4()
      # attributes this should not be accessed directly
      @attributes ||= {}
      # the list of attached events  - the only event is change
      @_events = []
      #dirty list of attributes
      @_dirty = {}
    #this is very similar functionally to Backbone.model obj.set({key:val},{silent:true})
    set:(attrs,options={})->
      #this is to prevent the programmer from thinking this would work
      throw "attrs must be an object" unless typeof attrs == "object"
      changedAttributes = []
      for k,v of attrs
        if @attributes[k] != v
          changedAttributes.push k
          #set dirty attributes with new value
          @_dirty[k]=v
          @attributes[k] = v
      #if silent is set don't call the change event
      if !options.silent && changedAttributes.length>0
        f.apply(@,[@,changedAttributes]) for f in @_events
    #change function pass in a function you want to add on change event
    change:(f)->
      if f and typeof f == "function"
        @_events.push f
      else unless f
        f.apply(@,arguments) for f in @_events
    #not sure about this feel like this functionality should be encapsulated but would need to encapsulate syncing...
    _cleanDirty:()->
      @_dirty = {}
    # returns the delta and cleans out dirty it also includes the list of constant fields if they are defined
    # this is useful if you want to always pass id type fields
    changedFields:()->
      params = {}
      for k,v of @_dirty
        params[k] = v
      if @constantFields
        for field in @constantFields
          params[field] = @attributes[field] if @attributes[field]
      @_cleanDirty()
      params
    #returns the object as a querystring
    serialize:()->
      utils.toQuery(@attributes)
    #sets the object from a given query string
    deserialize:(str)->
      @set(utils.fromQuery(str),silent:true)



