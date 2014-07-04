# Defines Actions requested to be performed by front-end
#
# All methods 
#   - take an argument 'message'
#   - take an optional argument 'port', used to post message back to front
#     if needed
#   - returns a message object that'll be posted after its execution
#
# Sometimes async operations can't return result immediately
# A message taking the form
# {
#   response: 'a_action'
#   data...
# }
# will be posted to frontend
#

Action =
  search: (message) ->
    response: 'search'
    result: Bookmark.find(message.input)
  
  # ------------------------------------------------------------

  # Opening bookmarks
  open: (message) ->
    if message.node
      chrome.tabs.create
        url: message.node.url
        active: message.option.active
    else
      _.forEach message.nodeArray, (node) ->
        chrome.tabs.create
          url: node.url
          active: message.option.active

    { response: 'open' }

  openInNewWindow: (message) ->
    if message.node
      url = message.node.url
    else
      url = _.pluck(message.nodeArray, 'url')

    chrome.windows.create
      url: url
      incognito: message.option.incognito

    { response: 'openInNewWindow' }

  # ------------------------------------------------------------

  addTag: (message) ->
    if message.node
      _.forEach message.tagArray, (tag) ->
        Bookmark.addTag(message.node, tag)
        true # do not exit early
    else
      _.forEach message.nodeArray, (node) ->
        _.forEach message.tagArray, (tag) ->
          Bookmark.addTag(node, tag)
          true # do not exit early

    Bookmark.storeTag()

    { response: 'addTag' }


  storeTag: (message, port) ->
    Bookmark.storeTag()

    port.postMessage
      response: 'a_storeTag'

    { response: 'storeTag' }

  # ------------------------------------------------------------

  queryTab: (message, port) ->
    chrome.tabs.query message.queryInfo, (tabArray) ->
      port.postMessage
        response: 'a_queryTab'
        tabArray: tabArray

    { response: 'queryTab' }

  # ------------------------------------------------------------
  # Bookmark Operation
  # ------------------------------------------------------------

  addBookmark: (message) ->
    Bookmark.create(message.bookmark, message.tagArray)

    { response: 'addBookmark' }

