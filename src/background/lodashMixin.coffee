startsWith = (str, start) ->
  str.lastIndexOf(start, 0) is 0

ciContains = (str, start) ->
  startsWith(str.toLowerCase(), start.toLowerCase())

ciEquals = (s1, s2) ->
  s1.toLowerCase() is s2.toLowerCase()
  
_.mixin({ startsWith, ciContains, ciEquals })
