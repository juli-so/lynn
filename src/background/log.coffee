# #############################################################################
# 
# Test Utility for easier testing in chrome
#
##############################################################################

log = (item) -> console.log(item)
c = console

logArr = (strArr) ->
  logStr = _.reduce(strArr, (prev, next) ->
    prev + next
  )
  log(logStr)

makeCharString = (charNum, char = ' ') ->
  new Arr(charNum + 1).join(char)

makeUniform = (str, length, char=' ') ->
  diff = length - str.length
  str + makeCharString(diff)

pad = (str, length, char = ' ') ->
  makeCharString(length, char) + str

logNodeTag = (node, charNum, char = ' ') ->
  if node.tagArr.length > 0
    nodeStr = node.tagArr.join(' ')
    log(pad(nodeStr, charNum))
  else
    log(pad('Node Arr: Empty', charNum))

logNodeArr = (nodeArr, property = 'all') ->
  log('==================================================')
  switch property
    when 'all'
      c.group('###Log all###')
      _.forEach(nodeArr, (node) ->
        c.group('Bookmark : ' + makeUniform(node.id, 4) + ' | ' + node.title)
        c.log("%c  " + node.url, "color: darkblue")
        logNodeTag(node, 2)
        c.groupEnd()
      )
      c.groupEnd()
    when 'tag'
      log('###Log tag###')
      _.forEach(nodeArr, (node) ->
        log('  ' + node.title)
        logNodeTag(node, 4)
      )
    when 'title'
      log('###Log title###')
      _.forEach(nodeArr, (node) ->
        log('  ' + node.title)
      )
    when 'id'
      log('###Log id###')
      _.forEach(nodeArr, (node) ->
        log('  ' + makeUniform(node.id, 4) + ' | ' + node.title)
      )
    when 'url'
      log('###Log url###')
      _.forEach(nodeArr, (node) ->
        log(makeUniform(node.id, 4) + ' | ' + node.title)
        if node.isBookmark
          log('  ' + node.url)
        else
          log('  Directory')
      )
    when 'children'
      log('###Log children###')
      _.forEach(nodeArr, (node) ->
        if node.isBookmark
          log('  Bookmark')
        else
          log('  ' + node.children.length + ' children')
          _.forEach(node.children, (child) ->
            if child.isBookmark
              log('    Bookmark : ' + makeUniform(child.id, 4) + ' | ' + child.title)
            else
              log('    Directory: ' + makeUniform(child.id, 4) + ' | ' + child.title)
          )
      )
  log('==================================================')

#Aliases 
lna = logNodeArr
