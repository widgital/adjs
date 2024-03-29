module.exports = do ->
  #The applications configuration
  #the build process sets the environment
  #Minifying will remove everything but the expected values
  return if process.env.ENV == "test"
    api: '//endpoint.adjs.dev:8080/1'
    cdn_url: 'base/lib/html/adjsframe.html'
    controller_url: "base/lib/html/controllerframe.html"
    ad_url: "base/lib/html/adframe.html"
    visit_expiry: 0.03
    version:"0.0.1"
    domain:"localhost"
  else if process.env.ENV == "production"
    api: "//api.adjs.net/1"
    cdn_url: "//cdn.adjs.net/html/adjsframe.html"
    visit_expiry: 30
    version:"0.0.1"
    domain:"adjs.net"
    controller_url:"//cdn.adjs.net/html/controllerframe.html"
    ad_url: "//cdn.adjs.net/html/adframe.html"
  else if process.env.ENV == "staging"
    api: "//api.adjs.net/1"
    cdn_url: "//s3.amazonaws.com/js.adjsdemo.com/html/adjsframe.html"
    visit_expiry: 30
    version:"0.0.1"
    domain:"s3.amazonaws.com"
    controller_url:"//s3.amazonaws.com/js.adjsdemo.com/html/controllerframe.html"
    ad_url: "//s3.amazonaws.com/js.adjsdemo.com/html/adframe.html"
  else
    api: '//endpoint.adjs.dev:8080/1'
    cdn_url: 'http://cdn.adjs.dev:9080/html/adjsframe.html'
    visit_expiry: 3
    version:"0.0.1"
    domain:"adjs.dev"
    controller_url: "http://cdn.adjs.dev:9080/html/controllerframe.html"
    ad_url:  "http://cdn.adjs.dev:9080/html/adframe.html"
