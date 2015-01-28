# ---------------------------------------------------------------------------- #
#                                                                              #
# Use sessions to store & recover pages in bulk                                #
#                                                                              #
# ---------------------------------------------------------------------------- #

Session =
  sessionMap: {}

  init: ->
    chrome.storage.local.get 'sessionMap', (storObj) =>
      @sessionMap = storObj.sessionMap || {}

  search: (input) ->
    sessionRecord = _.find @sessionMap, (s, sName) ->
      _.ciStartsWith(sName, input)

    sessionRecord || []

  storeWin: (sessionName, cb) ->
    currentWinTabArr = WinTab.g_currWinTabArr()

    @sessionMap[sessionName] =
      type: 'window'
      session: currentWinTabArr

    chrome.storage.local.set { sessionMap: @sessionMap }, ->
      cb()

  storeAll: (sessionName, cb) ->
    allTabArr = Win.g_allTabArr()
    session = _.values(_.groupBy(allTabArr, 'windowId'))

    @sessionMap[sessionName] =
      type: 'chrome'
      session: session

    chrome.storage.local.set { sessionMap: @sessionMap }, ->
      cb()

  remove: (input, cb) ->
    sessionName = _.findKey @sessionMap, (s, sName) ->
      _.ciStartsWith(sName, input)

    if sessionName
      delete @sessionMap[sessionName]
      chrome.storage.local.set { sessionMap: @sessionMap }, ->
        cb()
