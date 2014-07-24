Base = require './shared/base'

module.exports = do (window)->
  # Request object
  # Just declares constant fields, identical to base
  class Request extends Base
    constructor:()->
      super
    path:"/event"
    constantFields:[
      "site_user_id",
      "page_id",
      "visit_id",
      "url",
      "req_id"
    ]


  return Request