# ---------------------------------------------------------------------------- #
#                                                                              #
# Wrapper for setting Option and State in chrome.storage.local                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

CStorage =

  # Defaults for Option/State when they are first created
  defaultOption: {
    MAIN_SHORTCUT: 'b'
    MAX_SUGGESTION_NUM: 8
    MAX_RECOVER_NUM: 10
  }

  defaultState: {
    lastDeletedNodeArr: []
    sessionMap: {}
    autoTaggingMap: {}
  }

  # Call cb with all options if 'null' is passed
  # Call cb with default values for unspecified options 
  # Call cb with an object of all requested options, if passed an array
  getOption: (optionNameOrArr, cb) ->
    chrome.storage.local.get null, (storObj) =>
      option = _.defaults({}, storObj['option'] || {}, @defaultOption)

      if _.isNull(optionNameOrArr)
        cb(option)
      else if _.isString(optionNameOrArr)
        cb(option[optionNameOrArr])
      else
        cb(_.at(option, optionNameOrArr))

  # Call cb with all state if 'null' is passed
  # Call cb with default values for unspecified states
  # Call cb with an object of all requested states, if passed an array
  getState: (stateNameOrArr, cb) ->
    chrome.storage.local.get null, (storObj) =>
      state = _.defaults({}, storObj['state'] || {}, @defaultState)

      if _.isNull(stateNameOrArr)
        cb(state)
      else if _.isString(stateNameOrArr)
        cb(state[stateNameOrArr])
      else
        cb(_.at(state, stateNameOrArr))

  setOption: (optionObj, cb) ->
    @getOption null, (option) =>
      option = _.assign({}, option, optionObj)
      
      chrome.storage.local.set { option }, ->
        cb(option) if cb

  setState: (stateObj, cb) ->
    @getState null, (state) =>
      state = _.assign({}, state, stateObj)
      
      chrome.storage.local.set { state }, ->
        cb(state) if cb

