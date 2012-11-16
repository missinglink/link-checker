httpClient    = require 'http'
defaultPort   = 80
defaultMethod = 'GET'

class Crawler

  # crawl an url passed using an HTTP client
  crawlUrl: (url, storeUrl, sendUrlStatus) ->    
    urlParts = require('url').parse url, true

    options =
      hostname: urlParts.hostname,
      port: urlParts.port || defaultPort,
      path: urlParts.path || '/',
      method: defaultMethod

    clientRequest = httpClient.request options, (res) ->
      sendUrlStatus url, res.statusCode
      storeUrl url, statusCode

    clientRequest.on 'error', (e) =>
      sendUrlStatus url, 500

    clientRequest.end()

module.exports = Crawler