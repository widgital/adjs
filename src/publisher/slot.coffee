sf = require 'safeframe'
sizes = require '../shared/sizes'
utils = require '../shared/utils'
events = require('../shared/event')(["request","click","load","view",
                                    "unload","focus","engage",
                                    "unfocus","expand","collapse","refreshed",
                                    "cookie","receive","unview","timeout"])
sfDom = sf.lib.dom

module.exports = do ->
  TIMEOUT_TIME  = 5000
  slots = {} # this should change tie objects to dom objects
  SCRIPT_REGEX = /<!--([\s\S]*)-->/
  # themselves so if removed browser takes care of cleanup
  class Slot
    constructor:(adId)->
      if @ instanceof Slot
        return @init(adId)
      else
        return new Slot(adId)
    init:(adId)->
      if slots[adId]
        return  slots[adId]
      @id= adId
      @count = 1
      slots[adId] = @
      @initEvents()
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
    refresh:(cb)->
      @remove()
      @count++
      @posMeta.setValue("load_n","extended",@count)
      sf.host.render(@pos)
      @frame = document.getElementById(@posConfig.dest)
      cb?(@)
      @refreshed()
      @
    trigger:(event)=>
      unless @options?.ignoreEvents
        events.trigger.apply @,arguments
        Slot.trigger event,@,arguments[1]
      @
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
    initEvents:->
      @request ->
        @requestTime = utils.now()
      @load ->
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
    notifyFrame:(cmd,data)->
      msgObj = sf.lib.lang.ParamHash()
      if @posConfig
        msgObj.pos = @posConfig.id
        msgObj.cmd = cmd
        msgObj.value = escape(data)
        sfDom.msghost.send(@posConfig.dest,msgObj.toString())

    create: (elem,html,@options={})->
      width = @options.width or elem.offsetWidth
      height = @options.height or elem.offsetHeight
      supports = {}
      for s in @options.supports or []
        supports[s] = true
      for s in @options.disables or []
        supports[s] = false
      return if @elem
      @elem = elem
      elem.id or=  sf.lib.lang.guid "pos"
      @posMeta = new sf.host.PosMeta null,"extended",
        inview: @options.inview
        session: @options.session
        host: document.location.hostname
        referrer: @options.referrer
        location: document.location.href
        slot_id: @id
        load_n: @count
      @posConfig = new sf.host.PosConfig
        id: @id
        dest:	elem.id
        w:  width
        h:	height
        supports: supports
        renderFile: @options.renderFile

      @pos	= new sf.host.Position(@posConfig.id, html, @posMeta)
      if @options.refresh_oov
        @unview ->
          setTimeout(
            =>@refresh()
          ,1)
      if @options.refresh_time?
        @refreshTime = sf.lib.lang.cnum(@options.refresh_time,0)
        if @refreshTime>0
          @load ->
            @startAutoRefresh(@refreshTime)
          @timeout ->
            @stopAutoRefresh()
            @refresh()
      sf.host.render(@pos)
      @frame = document.getElementById(elem.id)
      @
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
      sf.host.nuke(@id)
      @
    destroy:->
      @stopAutoRefresh()
      @remove()
      delete this.events
      delete slots[@id]
    reload:->
      if @options.inview
        @remove(true)
        sf.host.render(@pos)
        @frame = document.getElementById(@posConfig.dest)

    currentlyInview:->
      sf.host.inViewPercentage(@id) > 50 && @viewed
    inviewPercentage:->
      sf.host.inViewPercentage(@id)




  Slot.destroy = ()->
    ad.destroy() for _,ad of slots


  Slot.events = {}
  oldTrigger = Slot::trigger
  sf.lib.lang.mix(Slot::,events)
  Slot::trigger = oldTrigger
  sf.lib.lang.mix(Slot,events)


#    AdJS.setConfig = (config)->
#      $sf.lib.lang.mix(globalConfig,config)



  Slot.create = (d,session)->
    template = d.innerHTML.match(SCRIPT_REGEX)?[1] or d.innerHTML
    posId = sf.lib.lang.guid "pos"
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
      inview: sf.lib.lang.cbool(sfDom.attr(d,"data-inview"))
      refresh_time: sfDom.attr(d,"data-refresh-time")
      refresh_oov: sf.lib.lang.cbool(sfDom.attr(d,"data-refresh-oov"))
      session: session?.serializeCookie()
      referrer: sfDom.attr(d,"data-referrer")
      ignoreEvents:  sf.lib.lang.cbool(sfDom.attr(d,"data-ignore-events"))
    Slot(adId)

  Slot.slots = slots
  Slot.sizes = sizes




  Slot