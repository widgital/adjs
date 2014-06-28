module.exports = (eventNames)->
  do ()->
    events =
      on:(event,cb)->
        @events or={}
        eventList = @events[event] or []
        eventList.push cb
        @events[event] = eventList
        @
      ###
        optionalData needs to be fixed
      ###
      trigger:(event,data,optionalData)->
        @events or= {}
        for e in @events[event] or []
          try
            e.call(@,data,optionalData)
          catch ex
            #do nothing other events bubble
        @
    for event in eventNames
      events[event] = do (event)->
        f = (data)->
          if typeof data == "function"
            @on(event,data)
          else
            @trigger(event,data)
    events




