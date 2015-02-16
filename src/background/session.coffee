# ---------------------------------------------------------------------------- #
#                                                                              #
# Use sessions to store & recover pages in bulk                                #
#                                                                              #
# ---------------------------------------------------------------------------- #

Session =
  search: (input) ->
    sessionMap = CStorage.getState('sessionMap')
    
    _.find sessionMap, (s, sName) ->
      _.ciStartsWith(sName, input)

  storeWin: (sessionName, tabArr, cb) ->
    sessionMap = CStorage.getState('sessionMap')

    sessionMap[sessionName] =
      name: sessionName
      type: 'window'
      session: tabArr

    CStorage.setState('sessionMap', sessionMap, cb)

  storeAll: (sessionName, tabArr, currWinId, cb) ->
    sessionMap = CStorage.getState('sessionMap')

    tabArrGroups = _.groupBy(tabArr, 'windowId')
    currWinTabArr = tabArrGroups[currWinId]
    
    session = _.without(_.values(tabArrGroups), currWinTabArr)
    session.unshift(currWinTabArr)

    sessionMap[sessionName] =
      name: sessionName
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
