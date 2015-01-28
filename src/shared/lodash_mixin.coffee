# ---------------------------------------------------------------------------- #
#                                                                              #
# Lodash mixin                                                                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

MixinObj =
  startsWith: (str, start) ->
    str.lastIndexOf(start, 0) is 0

  ciStartsWith: (str, start) ->
    @startsWith(str.toLowerCase(), start.toLowerCase())

  ciEquals: (s1, s2) ->
    s1.toLowerCase() is s2.toLowerCase()

  ciContains: (str, start) ->
    _.contains(str.toLowerCase(), start.toLowerCase())

  # Check if arr contains element that ciEquals to str
  ciArrContains: (arr, str) ->
    _.any arr, (e) => @ciEquals(e, str)

  # Find first element in arr that ciEquals to str
  ciArrFind: (arr, str) ->
    _.find arr, (e) => @ciEquals(e, str)
  
# Currify and mixin

_.mixin(_.mapValues(MixinObj, _.curry))
