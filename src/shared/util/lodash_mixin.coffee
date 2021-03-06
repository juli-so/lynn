# ---------------------------------------------------------------------------- #
#                                                                              #
# Lodash mixin                                                                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

MixinObj =
  ciStartsWith: (str, start) ->
    _.startsWith(str.toLowerCase(), start.toLowerCase())

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

  clearArr: (arr) ->
    while(arr.length > 0)
      arr.pop()

  # Pick a random item from array and remove it
  randPopFromArr: (arr) ->
    _.pullAt(arr, Math.floor(Math.random() * arr.length))

  toTwoDec: (num) ->
    parseFloat (Math.round(num * 100) / 100).toFixed(2)
  
# Currify and mixin

_.mixin(_.mapValues(MixinObj, _.curry))
