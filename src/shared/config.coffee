module.exports = do ->
  return if process.env.ENV == "test"
    api: '//endpoint.adjs.dev:8080/1'
    cdn_url: 'base/lib/html/adjsframe.html'
    controller_url: "base/lib/html/controllerframe.html"
    visit_expiry: 1
    version:"0.0.1"
    domain:"localhost"
  else if process.env.ENV == "production"
    api: "//endpoint.adjs.io/1"
    cdn_url: process.env.CDN_URL
    visit_expiry: 30
    version:"0.0.1"
    domain:"adjs.net"
  else
    api: '//endpoint.adjs.dev:8080/1'
    cdn_url: '../lib/html/adjsframe.html'
    visit_expiry: 3
    version:"0.0.1"
    domain:"localhost"
    controller_url: "../lib/html/controllerframe.html"
