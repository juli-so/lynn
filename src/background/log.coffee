# ---------------------------------------------------------------------------- #
#                                                                              #
# For easier testing in Chrome                                                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

log = -> console.log.apply(console, arguments)

# ------------------------------------------------------------
# Helper
# ------------------------------------------------------------

makeCharString = (charNum, char = ' ') ->
  new Array(charNum + 1).join(char)

makeUniform = (str, length, char=' ') ->
  diff = length - str.length
  str + makeCharString(diff)

pad = (str, length, char = ' ') ->
  makeCharString(length, char) + str

logNodeTag = (node, charNum, char = ' ') ->
  if node.tagArr.length > 0
    nodeStr = node.tagArr.join(' ')
    log("%c" + pad(nodeStr, charNum), "color: green")
  else
    log("%c" + pad('∅', charNum), "color: red")

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

nodeLog = (nodeArrOrObject) ->
  c = console

  if _.isObject(nodeArrOrObject)
    nodeArr = _.values(nodeArrOrObject)
  else
    nodeArr = nodeArrOrObject

  log('==================================================')

  _.forEach(nodeArr, (node) ->
    c.group("Bookmark " + node.id)
    c.log("%c" + pad(node.title, 2), "font-weight: bold")
    c.log("%c" + pad(node.url  , 2), "font-weight: bold")
    if node.tagArr
      logNodeTag(node, 2)
    else
      log("%c" + pad('∅', 2), "color: red")

    c.groupEnd()
  )

  log('==================================================')

nl = nodeLog

