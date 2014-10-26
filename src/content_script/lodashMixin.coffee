startsWith = (str, start) ->
  str.lastIndexOf(start, 0) is 0

ciContains = (str, start) ->
  _.contains(str.toLowerCase(), start.toLowerCase())

ciEquals = (s1, s2) ->
  s1.toLowerCase() is s2.toLowerCase()
  
startsWith = _.curry(startsWith)
ciContains = _.curry(ciContains)
ciEquals   = _.curry(ciEquals)

_.mixin({ startsWith, ciContains, ciEquals })
