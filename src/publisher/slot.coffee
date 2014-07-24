#[Sizes](./sizes.html)
sizes = require '../shared/sizes'
#[Utils](./utils.html)
utils = require '../shared/utils'
#[Events](./event.html)
events = require('../shared/event')(["request","click","load","view",
                                    "unload","focus","engage",
                                    "unfocus","expand","collapse","refreshed",
                                    "cookie","receive","unview","timeout"])


module.exports = do ($sf)->
  sfDom = $sf.lib.dom
  # Create the collection of slots
  slots = {}
  # regex to find the content of a tag
  SCRIPT_REGEX = /<!--([\s\S]*)-->/

  # Publisher Slot class, this represents the slot on the page. This can be accessed by the publisher
  # It remains in memory until its destroyed. It can be accessed via Slot("name") which will persist it
  class Slot
    #create the slot is the same as Slot(adId)
    constructor:(adId)->
      if @ instanceof Slot
        return @init(adId)
      else
        return new Slot(adId)
    init:(adId)->
      if slots[adId]
        return  slots[adId]
      @id= adId
      #every time the ad is refreshed the count goes up for the slot
      @count = 1
      #we then add the Slot object to our persisted collection
      slots[adId] = @
      @initEvents()
    #
    #Autorefresh
    #-----------
    #
    #If the div to build the ad slot has data-refresh-time=<time_value>
    #These functions are used to start them. A timeout is set and reset after every refreshed ad is loaded

    startAutoRefresh:(delay=60,cb)->
      unless @_isAutoRefreshing
        @_isAutoRefreshing =true
        @_refreshInterval = setTimeout(=>
          @_isAutoRefreshing = false
          if @loadTime
            @refresh(cb)
        ,delay*1000)
      @
    stopAutoRefresh:()->
      clearTimeout(@_refreshInterval)
      @_isAutoRefreshing= false
      @_refreshInterval = null
      @
    #refresh the ad and increase the count
    refresh:(cb)->
      @remove()
      @count++
      @posMeta.setValue("load_n","extended",@count)
      $sf.host.render(@pos)
      @frame = document.getElementById(@posConfig.dest)
      cb?(@)
      @refreshed()
      @
    #override the events trigger to trigger events and allow 'dumb' slots to not do anything
    trigger:(event)=>
      unless @options?.ignoreEvents
        events.trigger.apply @,arguments
        # call the global trigger
        Slot.trigger event,@,arguments[1]
      @
    # this gets called when a message is received from a safeframe
    # object is mutated and/or events are fired as necessary based on the message sent
    handleMessage:(msg,content)->
      return switch msg
        when "focus-change"
          if content then @focus() else @unfocus()
        when "geom-update" then ->
        when "expand" then @expand(content)
        when "collapse" then @collapse(content)
        when "viewed" then @view() unless @viewed
        when "unviewed" then @unview() unless @unviewed && @viewed
        when "clicked" then @click() unless @clicked
        when "requested" then @request()
        when "cookie-write" then @cookie(cookie:"write",content: content)
        when "cookie-read" then @cookie(cookie:"read",content:content)
        when "reload" then @reload()
        when "msg" then @receive(decodeURIComponent(content))
        else null
    #
    #  Events
    #  -----------
    #
    #  Slots are event driven. We have a number of events that are standardised that can be used on a slot:
    #
    #  event name | description
    #  -----------|--------------
    #  request | occurs when the ad is requested
    #  click | occurs when the ad is clicked
    #  load | occurs when the ad has been loaded
    #  view | Occurs when greater than 50% of the ad is in view for greater than 1 second
    #  unload | Occurs when the ad is removed
    #  focus | occurs when the ad has gained focus
    #  unfocus | occurs when the ad loses focus
    #  engage | occurs when there is engagement and the view event has already fired
    #  expand | occurs when the ad has expanded
    #  collapse | occurs when the ad has collapsed
    #  refreshed | occurs when the ad has refreshed
    #  cookie | occurs when the ad sets a cookie
    #  receive | enables the advertiser to send custom messages to the publisher this is called with the message body
    #  unview | occurs when a viewed ad leaves view
    #  timeout | occurs when the slot timeouts loading an ad
    #
    #  initEvents initializes the internal ads for state changes

    initEvents:->
      @request ->
        @requestTime = utils.now()
      @load ->
        #figure out the load chain, i.e. how many different ad providers deep are in this one slot
        @loadChain = utils.countFrames(@frame.contentWindow)
        @loadTime = utils.now()
      @view ->
        @viewed = true
        @viewTime = utils.now()
      @engage ->
        unless @engaged
          @engaged = true
          @engageTime = utils.now()
          @notifyFrame("engaged")
      @unview ->
        @unviewed = true
        @unviewTime = utils.now()
      @unload ->
        @unloadTime = utils.now()
      @click ->
        @clicked = true
    loadChain: 0
    #from the slot you can send a message to the safeframe
    notifyFrame:(cmd,data)->
      msgObj = $sf.lib.lang.ParamHash()
      if @posConfig
        msgObj.pos = @posConfig.id
        msgObj.cmd = cmd
        msgObj.value = escape(data)
        sfDom.msghost.send(@posConfig.dest,msgObj.toString())

    # create generates the safeframe and ties it to the slot.
    create: (elem,html,@options={})->
      width = @options.width or elem.offsetWidth
      height = @options.height or elem.offsetHeight
      supports = {}
      # this ties into defaults for safeframe in this case
      # the valid supports are 'read-cookie','write-cookie','exp-push'
      for s in @options.supports or []
        supports[s] = true
      # valid disables are 'exp-ovr
      for s in @options.disables or []
        supports[s] = false
      # don't recreate the safeframe
      return if @elem
      @elem = elem
      elem.id or=  $sf.lib.lang.guid "pos"
      #generate safeframe metadata
      @posMeta = new $sf.host.PosMeta null,"extended",
        inview: @options.inview
        page: @options.page
        host: document.location.hostname
        referrer: @options.referrer
        location: document.location.href
        slot_id: @id
        load_n: @count
      #generate safeframe posish data
      @posConfig = new $sf.host.PosConfig
        id: @id
        dest:	elem.id
        w:  width
        h:	height
        supports: supports
        renderFile: @options.renderFile
      @pos	= new $sf.host.Position(@posConfig.id, html, @posMeta)
      #attach out of view event if its an option
      if @options.refresh_oov
        @unview ->
          setTimeout(
            =>@refresh()
          ,1)
      #attach autorefresh event if its an option after load
      if @options.refresh_time?
        @refreshTime = $sf.lib.lang.cnum(@options.refresh_time,0)
        if @refreshTime>0
          @load ->
            @startAutoRefresh(@refreshTime)
          @timeout ->
            @stopAutoRefresh()
            @refresh()
      # render the safeframe!
      $sf.host.render(@pos)
      # get a reference to the frame object, this is useful to find out the total ad depth
      @frame = document.getElementById(elem.id)
      @
    #remove the ad slot - don't fire is for only load when in view
    # this is in use essentially to allow doc.write in the frame itself.
    # the actual solution involves nesting a second iframe inside the safeframe to properly enable this functionality
    remove:(dontFire)->
      @unload() unless dontFire
      clearTimeout(@_refreshInterval)
      @viewed = false
      @engaged = false
      @unviewed = false
      @frame = null
      @frameCount = 0
      @requestTime = null
      @loadTime = null
      @viewTime = null
      @engageTime = null
      @unviewTime = null
      @unloadTime = null
      $sf.host.nuke(@id)
      @
    #destroy the add and remove all traces of it from memory
    destroy:->
      @stopAutoRefresh()
      @remove()
      delete this.events
      delete slots[@id]
    #this is a poorly named function for loading the ad when the slot is inview
    reload:->
      if @options.inview
        @remove(true)
        $sf.host.render(@pos)
        @frame = document.getElementById(@posConfig.dest)
    # when the ad fits our definition of inview:
    # greater than 50% of the ad is in view for greater than 1 second
    currentlyInview:->
      $sf.host.inViewPercentage(@id) > 50 && @viewed
    # the current percentage of an ad that is in view
    inviewPercentage:->
      $sf.host.inViewPercentage(@id)

  #destroy all ad slots
  Slot.destroy = ()->
    ad.destroy() for _,ad of slots

  #initialize events with the slot
  Slot.events = {}
  #override default trigger after the mix
  oldTrigger = Slot::trigger
  $sf.lib.lang.mix(Slot::,events)
  Slot::trigger = oldTrigger
  $sf.lib.lang.mix(Slot,events)


  #    Slot creation
  #    -------------
  #
  #    The slot gets created by passing a div with various data attributes. That make it behave in different ways.
  #
  #  | attribute     | description                                                                                                     |
  #  |---------------|-----------------------------------------------------------------------------------------------------------------|
  #  | adjs          | required, must be set to true in order for the script to know it exists                                         |
  #  | ad-type       | determines width and height for IAB standard ad units i.e. leaderboard                                          |
  #  | width         | the ads width instead of using ad-type                                                                          |
  #  | height        | the ads height instead of using ad-type                                                                         |
  #  | escaped       | if the content is escaped html true,false                                                                       |
  #  | supports      | safeframe supported features:  write-cookie,read-cookie, exp-push                                               |
  #  | disables      | safeframe disabled features: exp-ovr                                                                            |
  #  | inview        | only show ad if its inview true,false                                                                           |
  #  | refresh-time  | the time in seconds for the ad to be refreshed                                                                  |
  #  | refresh-oov   | refresh the ad when out of view after it has been viewed  true,false                                            |
  #  | referrer      | the visibility of the referrer to the ad (experimental) - all,host,none                                         |
  #  | ignore-events | ignore events useful if you want a frame with the adjs domain that you have code you want to talke between them |
  #
  #
  #    Here is an example
  #
  #    ```
  #      <div data-adjs="true" data-width="728" data-height="90" id="unique-id-of-slot" data-refresh-time="60" data-inview="true"  >
  #      <!--
  #        <script src="http://example.com/adserver.id.js"/>
  #      -->
  #      </div>
  #    ```

  Slot.create = (d,page)->
    template = d.innerHTML.match(SCRIPT_REGEX)?[1] or d.innerHTML
    isEscaped = $sf.lib.lang.cbool(sfDom.attr(d,"data-escaped"))
    template = $sf.lib.lang.jsunsafe_html(template) if isEscaped
    posId = $sf.lib.lang.guid "pos"
    adId = d.id or posId
    div = document.createElement "div"
    div.id = posId
    d.appendChild div
    supports = []
    disables = []
    if size = sizes[sfDom.attr(d,"data-ad-type")]
      [width,height] = size
    Slot(adId).create div,template,
      width:width or sfDom.attr(d,"data-width")
      height:height or sfDom.attr(d,"data-height")
      supports: sfDom.attr(d,"data-supports").split?(",")
      disables: sfDom.attr(d,"data-disables").split?(",")
      inview: $sf.lib.lang.cbool(sfDom.attr(d,"data-inview"))
      refresh_time: sfDom.attr(d,"data-refresh-time")
      refresh_oov: $sf.lib.lang.cbool(sfDom.attr(d,"data-refresh-oov"))
      page: page?.serialize()
      referrer: sfDom.attr(d,"data-referrer")
      ignoreEvents:  $sf.lib.lang.cbool(sfDom.attr(d,"data-ignore-events"))
    Slot(adId)

  Slot.slots = slots
  Slot.sizes = sizes




  Slot