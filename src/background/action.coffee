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
      _.forEach message.tagArray, (tag) ->
        Bookmark.addTag(message.node, tag)
        true # do not exit early
    else
      _.forEach message.nodeArray, (node) ->
        _.forEach message.tagArray, (tag) ->
          Bookmark.addTag(node, tag)
          true # do not exit early

    Bookmark.storeTag()

  storeTag: (message) ->
    Bookmark.storeTag()

  # ------------------------------------------------------------

  queryTab: (message) ->
    response: 'queryTab'
    tabArray: Tab.tabArray
    current: Tab.current

  # ------------------------------------------------------------

  addGroup: (message, port) ->
    chrome.storage.sync.get 'groupMap', (storageObject) ->
      groupMap = storageObject.groupMap
      tabArray = _.filter Tab.tabArray, (tab) ->
        tab.windowId is Tab.current.windowId
      simplifiedTabArray = _.map tabArray, (tab) ->
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

  # ------------------------------------------------------------
  # Bookmark Operation
  # ------------------------------------------------------------
  _getHostname: (url) ->
    a = document.createElement('a')
    a.href = url
    a.hostname

  addBookmark: (message) ->
    hostname = @_getHostname(message.bookmark.url)
    tagArray = Tag.autoTag(message.bookmark.title, hostname)
    tagArray = _.uniq(tagArray.concat(message.tagArray))
    Bookmark.create(message.bookmark, tagArray)

  removeBookmark: (message) ->
    Bookmark.remove(message.id)
