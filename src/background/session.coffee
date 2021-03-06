# ---------------------------------------------------------------------------- #
#                                                                              #
# Use sessions to store & recover pages in bulk                                #
#                                                                              #
# ---------------------------------------------------------------------------- #

Session =
  search: (input, cb) ->
    CStorage.getState 'sessionMap', (sessionMap) ->
      sessionRecord = _.find sessionMap, (s, sName) ->
        _.ciStartsWith(sName, input)

      cb(sessionRecord)

  storeWin: (sessionName, tabArr, cb) ->
    CStorage.getState 'sessionMap', (sessionMap) ->
      sessionMap[sessionName] =
        name: sessionName
        type: 'window'
        session: tabArr

      CStorage.setState({ sessionMap }, cb)

  storeAll: (sessionName, tabArr, currWinId, cb) ->
    CStorage.getState 'sessionMap', (sessionMap) ->
      tabArrGroups = _.groupBy(tabArr, 'windowId')
      currWinTabArr = tabArrGroups[currWinId]
      
      # Current window tabs go first
      session = _.without(_.values(tabArrGroups), currWinTabArr)
      session.unshift(currWinTabArr)

      sessionMap[sessionName] =
        name: sessionName
        type: 'chrome'
        session: session

      CStorage.setState({ sessionMap }, cb)

  remove: (input, cb) ->
    CStorage.getState 'sessionMap', (sessionMap) ->
      sessionName = _.findKey sessionMap, (s, sName) ->
        _.ciStartsWith(sName, input)

      if sessionName
        delete sessionMap[sessionName]
        CStorage.setState({ sessionMap }, cb)
