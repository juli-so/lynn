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
    query = msg.input

    if _.startsWith(query, '$')
      sQuery = query[1..]
      sessionRecord = Session.search(sQuery)
      
      if sessionRecord
        nodeArr = Util.tabToNode(_.flatten(sessionRecord.session))
        res: 'search'
        result: Bookmark.tagify(nodeArr)
        sName: sessionRecord.name
      else
        res: 'search'
        result: []

    else
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

  setOption: (msg, done) ->
    CStorage.setOption(msg.optionObj, done)

  setState: (msg, done) ->
    CStorage.setState(msg.stateObj, done)

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
        Bookmark.addTag(msg.node.id, tag, false)
    else
      _.forEach msg.nodeArr, (node) ->
        _.forEach node.pendingTagArr, (tag) ->
          Bookmark.addTag(node.id, tag, false)

    Bookmark.storeTag()

  editTag: (msg) ->
    if msg.node
      Bookmark.delAllTag(msg.node.id)
      _.forEach msg.node.pendingTagArr, (tag) ->
        Bookmark.addTag(msg.node.id, tag, false)
    else
      _.forEach msg.nodeArr, (node) ->
        Bookmark.delAllTag(node.id)
        _.forEach node.tagArr.concat(node.pendingTagArr), (tag) ->
          Bookmark.addTag(node.id, tag, false)

    Bookmark.storeTag()

  tagify: (msg) ->
    res: 'tagify'
    nodeArr: Bookmark.tagify(msg.nodeArr)

  # ------------------------------------------------------------
  # Sessions
  # ------------------------------------------------------------

  searchSession: (msg) ->
    res: 'searchSession'
    sessionRecord: Session.search(msg.input)
  
  storeWinSession: (msg, done) ->
    Session.storeWin(msg.sessionName, msg.tabArr, done)

  storeChromeSession: (msg, done) ->
    Session.storeAll(msg.sessionName, msg.tabArr, msg.currWinId, done)

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
      tagMetaArr = []

      _.forEach msg.bookmarkArr, (bookmark) =>
        hostname = @_getHostname(bookmark.url)
        tagArr = Tag.autoTag(bookmark.title, hostname)
        tagMetaArr.push(tagArr)

      res: 'suggestTag'
      tagMetaArr: tagMetaArr

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

  deleteCurrentPageBookmark: (msg, done) ->
    WinTab.getCurrTab (tab) ->
      done({ nodeArr: _.values(Bookmark.fbExactURL(tab.url)) })

  # ------------------------------------------------------------
  # Others
  # ------------------------------------------------------------

  queryTab: (msg, done) ->
    WinTab.getAllTab(yes, done)

  stats: (msg) ->
    res: 'stats'
    stats: Bookmark.stats()
