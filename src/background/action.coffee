# ---------------------------------------------------------------------------- #
#                                                                              #
# Define actions requested to be performed by front end                        #
#                                                                              #
# All methods                                                                  #
#   - take an argument 'message'                                               #
#   - take an optional argument 'port', used to post message back when needed  #
#   - returns a message object that'll be posted back after its execution      #
#                                                                              #
# ---------------------------------------------------------------------------- #

Action =

  # ------------------------------------------------------------

  search: (msg) ->
    res: 'search'
    result: Bookmark.find(msg.input)
  
  # ------------------------------------------------------------

  getSyncStor: (msg, port) ->
    chrome.storage.sync.get null, (storObj) ->
      port.postMessage
        res: 'getSyncStor'
        storObj: storObj

  # ------------------------------------------------------------
  # Open bookmarks
  # ------------------------------------------------------------

  open: (msg) ->
    if msg.node
      chrome.tabs.create
        url: msg.node.url
        active: msg.option.active
    else
      _.forEach msg.nodeArr, (node) ->
        chrome.tabs.create
          url: node.url
          active: msg.option.active

  openInNewWin: (msg) ->
    if msg.node
      url = msg.node.url
    else
      url = _.pluck(msg.nodeArr, 'url')

    chrome.windows.create
      url: url
      incognito: msg.option.incognito

  # ------------------------------------------------------------
  # Tags
  # ------------------------------------------------------------

  addTag: (msg) ->
    if msg.node
      _.forEach msg.node.pendingTagArr, (tag) ->
        Bookmark.addTag(msg.node, tag)
    else
      _.forEach msg.nodeArr, (node) ->
        _.forEach node.pendingTagArr, (tag) ->
          Bookmark.addTag(node, tag)

    Bookmark.storeTag()

  editTag: (msg) ->
    if msg.node
      Bookmark.delAllTag(msg.node)
      _.forEach msg.node.pendingTagArr, (tag) ->
        Bookmark.addTag(msg.node, tag)
    else
      _.forEach msg.nodeArr, (node) ->
        Bookmark.delAllTag(node)
        _.forEach node.tagArr.concat(node.pendingTagArr), (tag) ->
          Bookmark.addTag(node, tag)
          true

    Bookmark.storeTag()

  delAllTag: (msg) ->
    if msg.node
      Bookmark.delAllTag(msg.node)
    else
      _.forEach msg.nodeArr, (node) ->
        Bookmark.delAllTag(node)

  storeTag: (msg) ->
    Bookmark.storeTag()

  # ------------------------------------------------------------
  # Sessions
  # ------------------------------------------------------------

  searchSession: (msg, port) ->
    chrome.storage.sync.get 'sessionMap', (storObj) ->
      { sessionMap } = storObj

      sessionRecord = _.find sessionMap, (s, sName) ->
        Util.ciStartsWith(sName, msg.input)
      sessionRecord or= []

      port.postMessage
        res: 'searchSession'
        sessionRecord: sessionRecord
  
  storeWinSession: (msg, port) ->
    chrome.storage.sync.get 'sessionMap', (storObj) ->
      { sessionMap } = storObj
      currentWinTabArr = WinTab.g_currWinTabArr()
      simplifiedTabArr = _.map currentWinTabArr, (tab) ->
        title: tab.title
        url: tab.url

      sessionMap[msg.sessionName] =
        type: 'window'
        session: simplifiedTabArr

      chrome.storage.sync.set { sessionMap }, ->
        port.postMessage { res: 'storeWinSession' }

  storeChromeSession: (msg, port) ->
    chrome.storage.sync.get 'sessionMap', (storObj) ->
      { sessionMap } = storObj
      tabArr = WinTab.g_allTabArr()
      session = _.values(_.groupBy(tabArr, 'windowId'))

      sessionMap[msg.sessionName] =
        type: 'chrome'
        session: session

      chrome.storage.sync.set { sessionMap }, ->
        port.postMessage { res: 'storeChromeSession' }

  removeSession: (msg, port) ->
    chrome.storage.sync.get 'sessionMap', (storObj) ->
      { sessionMap } = storObj

      sessionName = _.findKey sessionMap, (s, sName) ->
        Util.ciStartsWith(sName, msg.sessionName)

      if sessionName
        delete sessionMap[sessionName]
        chrome.storage.sync.set { sessionMap }, ->
          port.postMessage { res: 'removeSession' }

  # ------------------------------------------------------------
  # Adding / Removing Bookmark
  # ------------------------------------------------------------

  _getHostname: (url) ->
    a = document.createElement('a')
    a.href = url
    a.hostname

  suggestTag: (msg) ->
    if msg.bookmark
      hostname = @_getHostname(msg.bookmark.url)
      tagArr = Tag.autoTag(msg.bookmark.title, hostname)

      res: 'suggestTag'
      tagArr: tagArr
    else
      tagArrArr = []

      _.forEach msg.bookmarkArr, (bookmark) =>
        hostname = @_getHostname(bookmark.url)
        tagArr = Tag.autoTag(bookmark.title, hostname)
        tagArrArr.push(tagArr)

      res: 'suggestTag'
      tagArrArr: tagArrArr

  addBookmark: (msg) ->
    Bookmark.create(msg.bookmark, msg.tagArr)

  removeBookmark: (msg) ->
    if msg.id
      Bookmark.remove(msg.id)
    else
      _.forEach msg.idArr, (id) ->
        Bookmark.remove(id)

  queryDeletedBookmark: (msg) ->
    res: 'queryDeletedBookmark'
    nodeArr: Bookmark.lastDeletedNodeArr

  recoverBookmark: (msg) ->
    if _.isNumber(msg.index)
      Bookmark.recover(msg.index)
    else
      Bookmark.recover(msg.indexArr)

  # ------------------------------------------------------------
  # Others
  # ------------------------------------------------------------

  queryTab: (msg) ->
    res: 'queryTab'
    current: WinTab.g_currTab()
    tabArr: WinTab.g_allTabArr()
    currentWinTabArr: WinTab.g_currWinTabArr()

