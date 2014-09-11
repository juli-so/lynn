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

  lastWindow: (message) ->
    _.forEach Window.lastWindowTabArray, (tab) ->
      chrome.tabs.create
        url: tab.url
        active: yes
  
  lastWindowInBackground: (message) ->
    _.forEach Window.lastWindowTabArray, (tab) ->
      chrome.tabs.create
        url: tab.url
        active: no
  
  lastWindowInNewWindow: (message) ->
    urlArray = _.pluck(Window.lastWindowTabArray, 'url')
    chrome.windows.create
      url: urlArray
      incognito: no
  
  lastWindowInNewIncognitoWindow: (message) ->
    urlArray = _.pluck(Window.lastWindowTabArray, 'url')
    chrome.windows.create
      url: urlArray
      incognito: yes

  # ------------------------------------------------------------

  addTag: (message) ->
    if message.node
      _.forEach message.node.pendingTagArray, (tag) ->
        Bookmark.addTag(message.node, tag)
        true # do not exit early
    else
      _.forEach message.nodeArray, (node) ->
        _.forEach node.pendingTagArray, (tag) ->
          Bookmark.addTag(node, tag)
          true # do not exit early

    Bookmark.storeTag()

  editTag: (message) ->
    if message.node
      Bookmark.delAllTag(message.node)
      _.forEach message.node.pendingTagArray, (tag) ->
        Bookmark.addTag(message.node, tag)
        true # do not exit early
    else
      _.forEach message.nodeArray, (node) ->
        Bookmark.delAllTag(node)
        _.forEach node.tagArray.concat(node.pendingTagArray), (tag) ->
          Bookmark.addTag(node, tag)
          true

    Bookmark.storeTag()

  delAllTag: (message) ->
    if message.node
      Bookmark.delAllTag(message.node)
    else
      _.forEach message.nodeArray, (node) ->
        Bookmark.delAllTag(node)

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
    if message.id
      Bookmark.remove(message.id)
    else
      _.forEach message.idArray, (id) ->
        Bookmark.remove(id)

  queryDeletedBookmark: (message) ->
    response: 'queryDeletedBookmark'
    nodeArray: Bookmark.lastDeletedNodeArray

  recoverBookmark: (message) ->
    if message.index isnt undefined
      Bookmark.recover(message.index)
    else
      Bookmark.recover(message.indexArray)
