# #############################################################################
# 
# Test Utility for easier testing in chrome
#
##############################################################################

log = (item) -> console.log(item)
c = console

logArray = (strArray) ->
  logStr = _.reduce(strArray, (prev, next) ->
    prev + next
  )
  log(logStr)

makeCharString = (charNum, char = ' ') ->
  new Array(charNum + 1).join(char)

makeUniform = (str, length, char=' ') ->
  diff = length - str.length
  str + makeCharString(diff)

logNodeTag = (node, charNum, char = ' ') ->
  if node.tagArray.length > 0
    strArray = []
    strArray.push(makeCharString(charNum, char))
    logArray(strArray.concat(_.map(node.tagArray, (tag) ->
      if tag[0] == '@' then tag + ' ' else '#' + tag + ' '
    )))
  else
    log(makeCharString(charNum, char) + 'Node Array: Empty')

logNodeArray = (nodeArray, property = 'all') ->
  log('==================================================')
  switch property
    when 'all'
      c.group('###Log all###')
      _.forEach(nodeArray, (node) ->
        if Bookmark.nodeIsBookmark(node)
          c.group('Bookmark : ' + makeUniform(node.id, 4) + ' | ' + node.title)
          c.log("%c  " + node.url, "color: darkblue")
          logNodeTag(node, 2)
        else
          c.group('Directory: ' + makeUniform(node.id, 4) + ' | ' + node.title)
          log('  ' + node.children.length + ' children')
          logNodeTag(node, 2)
        c.groupEnd()
      )
      c.groupEnd()
    when 'tag'
      log('###Log tag###')
      _.forEach(nodeArray, (node) ->
        log('  ' + node.title)
        logNodeTag(node, 4)
      )
    when 'title'
      log('###Log title###')
      _.forEach(nodeArray, (node) ->
        log('  ' + node.title)
      )
    when 'id'
      log('###Log id###')
      _.forEach(nodeArray, (node) ->
        log('  ' + makeUniform(node.id, 4) + ' | ' + node.title)
      )
    when 'url'
      log('###Log url###')
      _.forEach(nodeArray, (node) ->
        log(makeUniform(node.id, 4) + ' | ' + node.title)
        if(Bookmark.nodeIsBookmark(node))
          log('  ' + node.url)
        else
          log('  Directory')
      )
    when 'children'
      log('###Log children###')
      _.forEach(nodeArray, (node) ->
        if(Bookmark.nodeIsBookmark(node))
          log('  Bookmark')
        else
          log('  ' + node.children.length + ' children')
          _.forEach(node.children, (child) ->
            if(Bookmark.nodeIsBookmark(child))
              log('    Bookmark : ' + makeUniform(child.id, 4) + ' | ' + child.title)
            else
              log('    Directory: ' + makeUniform(child.id, 4) + ' | ' + child.title)
          )
      )
  log('==================================================')

#Aliases 
lna = logNodeArray
