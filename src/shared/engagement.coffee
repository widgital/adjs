#[Utils](./utils.html)
utils = require './utils'
module.exports = do (window,$sf)->
  # this module attaches to every activity based event - when one occurs engagement is deemed to have occurred
  attach = $sf.lib.dom.attach
  engagement =
    isEngaged: false
  doc = window.document
  engageEvents = []
  disengageEvents = []
  ENGAGEMENT_RESET = 3000
  lastEngaged = undefined

  engagement.onEngagement = (f)->
    engageEvents.push f

  engagement.onDisengagement = (f)->
    disengageEvents.push f

  activityHandler = ->
    engagement.isEngaged = true
    engagement.lastEngaged = utils.now()
    f() for f in engageEvents
    resetEngagement()
    true

  engagementTimeout = null
  resetEngagement = ->
    clearTimeout(engagementTimeout)
    engagementTimeout = setTimeout(->
      engagement.isEngaged = false
      f() for f in disengageEvents
      disengageEvents=[]
    ,ENGAGEMENT_RESET)

  attach(doc,'click',activityHandler)
  attach(doc,'mouseup',activityHandler)
  attach(doc,'mousedown',activityHandler)
  attach(doc,'mousemove',activityHandler)
  attach(doc,'mousewheel',activityHandler)
  attach(doc,'keypress',activityHandler)
  attach(doc,'keydown',activityHandler)
  attach(doc,'keyup',activityHandler)
  attach(window,'DOMMouseScroll',activityHandler)
  attach(window,'scroll',activityHandler)
  attach(window,'resize',activityHandler)
  attach(window,'focus',activityHandler)
  attach(window,'blur',activityHandler)

  return engagement
