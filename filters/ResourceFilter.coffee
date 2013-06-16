Resource = require 'model/Resource'

absolutizeURI = require 'lib/utils/absolutizeURI'

url       = require 'url'
validator = require 'validator'


filter = (href, originDomain) ->
  throw new Error 'Invalid href' unless typeof href is 'string'
  throw new Error 'Invalid originDomain' unless typeof originDomain is 'string'
  validator.check(originDomain, 'Invalid originDomain').isUrl()
  
  href = getAbsoluteURI href, originDomain
  href = addDefaultProtocol href
  href = removeFragment href
  href = lowerCase href
  href = useCanonicalSlashes href
  href = removePort href
  return href


getAbsoluteURI = (href, originDomain) ->
  return absolutizeURI originDomain, href


removeFragment = (uri) ->
  return uri.split('#')[0]


addDefaultProtocol = (uri) ->
  defProtocol = Resource.defaultProtocol
  defProtocol = Resource.defaultProtocol + '//' unless /^\/\/.*$/.test uri
  return defProtocol + uri unless /^[a-z]+:/.test uri
  return uri


# Converting the scheme and host to lower case. 
# The scheme and host components of the URL are case-insensitive. Most normalizers will convert them to lowercase. 
# Example:
# HTTP://www.Example.com/ → http://www.example.com/
lowerCase = (uri) ->
  urlParts = url.parse uri
  urlParts.protocol = urlParts.protocol.toLowerCase()
  urlParts.hostname = urlParts.hostname.toLowerCase()
  return url.format urlParts


useCanonicalSlashes = (uri) ->
  up = url.parse uri
  if up.pathname isnt '/' and up.pathname.charAt(up.pathname.length-1) is '/'
    up.pathname = up.pathname.substring 0, up.pathname.length-1
  if up.path isnt '/' and up.path.charAt(up.path.length-1) is '/'
    up.path = up.path.substring 0, up.path.length-1
  return url.format up


# Removing the default port. 
# The default port (port 80 for the “http” scheme) may be removed from (or added to) a URL.
# Example:
# http://www.example.com:80/bar.html → http://www.example.com/bar.html
removePort = (uri) ->
  urlParts = url.parse uri
  urlParts.host = urlParts.host.replace /^(.*):[0-9]+(.*)$/, '$1$2'
  delete urlParts.port
  return url.format urlParts


module.exports = {
  filter
  getAbsoluteURI
  removeFragment
  addDefaultProtocol
  lowerCase
  useCanonicalSlashes
  removePort
}


# Capitalizing letters in escape sequences. 
# All letters within a percent-encoding triplet (e.g., "%3A") are case-insensitive, and should be capitalized.
# Example:
# http://www.example.com/a%c2%b1b → http://www.example.com/a%C2%B1b
# 
# Decoding percent-encoded octets of unreserved characters.
# For consistency, percent-encoded octets in the ranges of ALPHA (%41–%5A and %61–%7A), DIGIT (%30–%39), hyphen (%2D), period (%2E), 
# underscore (%5F), or tilde (%7E) should not be created by URI producers and, when found in a URI, should be decoded to their 
# corresponding unreserved characters by URI normalizers.[2] 
# Example:
# http://www.example.com/%7Eusername/ → http://www.example.com/~username/