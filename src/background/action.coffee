# Defines Actions requested to be performed by front-end
#
# All methods 
#   - take an argument 'message'
#   - take an optional argument 'port', used to post message back to front
#     if needed
#   - returns a message object that'll be posted after its execution
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
  # Open bookmarks
  # ------------------------------------------------------------

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
  # Open last opened windows
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
  # Tags
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
  # Sessions
  # ------------------------------------------------------------

  storeWindowSession: (message, port) ->
    chrome.storage.sync.get 'sessionMap', (storageObject) ->
      { sessionMap } = storageObject
      currentWindowTabArray = Tab.getCurrentWindowTabArray()
      simplifiedTabArray = _.map currentWindowTabArray, (tab) ->
        title: tab.title
        url: tab.url

      sessionMap[message.sessionName] =
        type: 'window'
        session: simplifiedTabArray

      chrome.storage.sync.set { sessionMap }, ->
        port.postMessage { response: 'storeWindowSession' }

  removeWindowSession: (message, port) ->
    chrome.storage.sync.get 'sessionMap', (storageObject) ->
      { sessionMap } = storageObject

      sessionName = _.findKey sessionMap, (s, sName) ->
        Util.ciStartsWith(sName, message.sessionName)

      if sessionName
        delete sessionMap[sessionName]
        chrome.storage.sync.set { sessionMap }, ->
          port.postMessage { response: 'removeWindowSession' }

  storeChromeSession: (message, port) ->
    chrome.storage.sync.get 'sessionMap', (storageObject) ->
      { sessionMap } = storageObject
      tabArray = Tab.tabArray
      session = _.values(_.groupBy(tabArray, 'windowId'))

      sessionMap[message.sessionName] =
        type: 'chrome'
        session: session

      chrome.storage.sync.set { sessionMap }, ->
        port.postMessage { response: 'storeChromeSession' }

      ###
      simplifiedTabArray = _.map currentWindowTabArray, (tab) ->
        title: tab.title
        url: tab.url

      sessionMap[message.sessionName] =
        type: 'window'
        session: simplifiedTabArray

      chrome.storage.sync.set { sessionMap }, ->
        port.postMessage { response: 'storeWindowSession' }
        ###

  searchSession: (message, port) ->
    chrome.storage.sync.get 'sessionMap', (storageObject) ->
      { sessionMap } = storageObject

      sessionRecord = _.find sessionMap, (s, sName) ->
        Util.ciStartsWith(sName, message.input)
      sessionRecord or= []

      port.postMessage
        response: 'searchSession'
        sessionRecord: sessionRecord
  
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

  # ------------------------------------------------------------
  # Others
  # ------------------------------------------------------------

  queryTab: (message) ->
    response: 'queryTab'
    current: Tab.current
    tabArray: Tab.tabArray
    currentWindowTabArray: Tab.getCurrentWindowTabArray()

