# ---------------------------------------------------------------------------- #
#                                                                              #
# Define actions requested to be performed by front end                        #
#                                                                              #
# All methods                                                                  #
#   - take an argument 'message'                                               #
#   - take an optional argument 'done' so action can end async                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

Action =

  # ------------------------------------------------------------

  search: (msg) ->
    res: 'search'
    result: Bookmark.find(msg.input)
  
  # ------------------------------------------------------------

  # If no input option is given return all option
  getOption: (msg) ->
    res: 'getOption'
    option: CStorage.getOption(msg.option || null)

  # If no input state is given return all state
  getState: (msg) ->
    res: 'getState'
    state: CStorage.getState(msg.state || null)

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

  searchSession: (msg) ->
    res: 'searchSession'
    sessionRecord: Session.search(msg.input)
  
  storeWinSession: (msg, done) ->
    Session.storeWin(msg.sessionName, done)

  storeChromeSession: (msg, done) ->
    Session.storeAll(msg.sessionName, done)

  removeSession: (msg, done) ->
    Session.remove(msg.sessionName, done)

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
    nodeArr: CStorage.getState('lastDeletedNodeArr')

  recoverBookmark: (msg) ->
    if _.isNumber(msg.index)
      Bookmark.recover(msg.index)
    else
      Bookmark.recover(msg.indexArr)

  # ------------------------------------------------------------

  deleteCurrentPageBookmark: (msg) ->
    res: 'deleteCurrentPageBookmark'
    nodeArr: _.values(Bookmark.fbExactURL(WinTab.g_currTab().url))

  # ------------------------------------------------------------
  # Others
  # ------------------------------------------------------------

  queryTab: (msg) ->
    res: 'queryTab'
    current: WinTab.g_currTab()
    tabArr: WinTab.g_allTabArr()
    currentWinTabArr: WinTab.g_currWinTabArr()

