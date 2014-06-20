module.exports = do ->
  return if process.env.ENV == "test"
    api: '//endpoint.adjs.dev:8080/1'
    cdn_url: 'base/lib/html/adjsframe.html'
  else if process.env.ENV == "production"
    api: "//endpoint.adjs.io/1"
    cdn_url: process.env.CDN_URL
  else
    api: '//endpoint.adjs.dev:8080/1'
    cdn_url: '../lib/html/adjsframe.html'