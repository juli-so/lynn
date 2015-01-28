# ---------------------------------------------------------------------------- #
#                                                                              #
# Use sessions to store & recover pages in bulk                                #
#                                                                              #
# ---------------------------------------------------------------------------- #

Session =
  search: (input) ->
    sessionMap = CStorage.getState('sessionMap')
    sessionRecord = _.find sessionMap, (s, sName) ->
      _.ciStartsWith(sName, input)

    sessionRecord || []

  storeWin: (sessionName, cb) ->
    sessionMap = CStorage.getState('sessionMap')
    currentWinTabArr = WinTab.g_currWinTabArr()

    sessionMap[sessionName] =
      type: 'window'
      session: currentWinTabArr

    CStorage.setState('sessionMap', sessionMap, cb)

  storeAll: (sessionName, cb) ->
    sessionMap = CStorage.getState('sessionMap')
    allTabArr = Win.g_allTabArr()
    session = _.values(_.groupBy(allTabArr, 'windowId'))

    sessionMap[sessionName] =
      type: 'chrome'
      session: session

    CStorage.setState('sessionMap', sessionMap, cb)

  remove: (input, cb) ->
    sessionMap = CStorage.getState('sessionMap')
    sessionName = _.findKey sessionMap, (s, sName) ->
      _.ciStartsWith(sName, input)

    if sessionName
      delete sessionMap[sessionName]
      CStorage.setState('sessionMap', sessionMap, cb)
