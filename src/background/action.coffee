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

  getSyncStorage: (message, port) ->
    chrome.storage.sync.get null, (storageObject) ->
      port.postMessage
        response: 'getSyncStorage'
        storageObject: storageObject

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

  openInNewWindow: (message) ->
    if message.node
      url = message.node.url
    else
      url = _.pluck(message.nodeArray, 'url')

    chrome.windows.create
      url: url
      incognito: message.option.incognito

  # ------------------------------------------------------------

  addTag: (message) ->
    if message.node
      _.forEach message.node.pendingTagArray, (tag) ->
        Bookmark.addTag(message.node, tag)
        true # do not exit early
    else
      _.forEach message.nodeArray, (node) ->
        _.forEach message.node.pendingTagArray, (tag) ->
          Bookmark.addTag(node, tag)
          true # do not exit early

    Bookmark.storeTag()

  storeTag: (message) ->
    Bookmark.storeTag()

  # ------------------------------------------------------------

  queryTab: (message) ->
    response: 'queryTab'
    current: Tab.current
    tabArray: Tab.tabArray
    currentWindowTabArray: Tab.getCurrentWindowTabArray()

  # ------------------------------------------------------------

  addGroup: (message, port) ->
    chrome.storage.sync.get 'groupMap', (storageObject) ->
      groupMap = storageObject.groupMap
      currentWindowTabArray = Tab.getCurrentWindowTabArray()
      simplifiedTabArray = _.map currentWindowTabArray, (tab) ->
        title: tab.title
        url: tab.url

      groupMap[message.groupName] = simplifiedTabArray

      chrome.storage.sync.set { groupMap }, ->
        port.postMessage { response: 'addGroup' }

  removeGroup: (message, port) ->
    chrome.storage.sync.get 'groupMap', (storageObject) ->
      groupMap = storageObject.groupMap
      delete groupMap[message.groupName]
      chrome.storage.sync.set { groupMap }, ->
        port.postMessage { response: 'removeGroup' }
  
  # ------------------------------------------------------------
  # Adding / Removing Bookmark
  # ------------------------------------------------------------

  _getHostname: (url) ->
    a = document.createElement('a')
    a.href = url
    a.hostname

  suggestTag: (message) ->
    if message.bookmark
      hostname = @_getHostname(message.bookmark.url)
      tagArray = Tag.autoTag(message.bookmark.title, hostname)

      response: 'suggestTag'
      tagArray: tagArray
    else
      tagArrayArray = []

      _.forEach message.bookmarkArray, (bookmark) =>
        hostname = @_getHostname(bookmark.url)
        tagArray = Tag.autoTag(bookmark.title, hostname)
        tagArrayArray.push(tagArray)

      response: 'suggestTag'
      tagArrayArray: tagArrayArray

  addBookmark: (message) ->
    Bookmark.create(message.bookmark, message.tagArray)

  removeBookmark: (message) ->
    Bookmark.remove(message.id)
