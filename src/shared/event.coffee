module.exports = (eventNames)->
  do ()->
    utils = require './utils'
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

        @notify(event,data or @)
        @

      notify: (event,data)->
        for endpoint in @eventEndpoints?[event] or []
          params = data?.getParams?() or {}
          params.event = event
          utils.sendRequest endpoint,
            data: params


    for event in eventNames
      events[event] = do (event)->
        f = (data)->
          if typeof data == "function"
            @on(event,data)
          else
            @trigger(event,data)
      events["#{event}RegisterEndpoint"] = do (event)->
        f = (endpoint)->
          @eventEndpoints or={}
          @eventEndpoints[event] or= []
          @eventEndpoints[event].push endpoint

    events




