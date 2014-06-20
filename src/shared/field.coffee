do ()->
  sendOnce = ["viewed","loaded","clicked","unload"]
  class Field
    constructor:(@fieldNm,@value)->
    serialize:()->
      return {} if @serialized
      @serialized = true if sendOnce.indexOf(@fieldName) > -1