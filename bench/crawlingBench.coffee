asyncBench = require 'async_bench'

# Crawler = require 'service/Crawler'

# crawlerService = new Crawler

Resource = require 'model/Resource'

asyncBench
  runs: 10000
  preHeat: 10000
  setup: (cb) ->
    cb()

  bench: (cb) ->    
    Resource.getAbsoluteURI '../../test.html', 'http://local.linkchecker.com'

    cb()

  complete: (err, results) ->
    if err
      throw err

    console.log results