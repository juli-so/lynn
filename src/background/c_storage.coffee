# ---------------------------------------------------------------------------- #
#                                                                              #
# Store / Get state & option to chrome.storage                                 #
#                                                                              #
# Option is shared between front/back                                          #
# Front-end state is handled by React                                          #
#                                                                              #
# ---------------------------------------------------------------------------- #

CStorage =
  option: {}
  state : {}

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

  # Use callback to ensure sequence of operation
  sync: (cb) ->
    chrome.storage.local.get null, (storObj) =>
      @option = storObj['option'] || {}
      @state  = storObj['state' ] || {}
      cb()

  clear: ->
    setObj =
      option: {}
      state : {}

    chrome.storage.local.set setObj, =>
      @option = {}
      @state  = {}

  setOption: (optionObj, cb) ->
    @option = _.assign(@option, optionObj)
    chrome.storage.local.set { option: @option }, ->
      if cb
        cb()

  setState: (stateObj, cb) ->
    @state = _.assign(@state, stateObj)
    chrome.storage.local.set { state: @state }, ->
      if cb
        cb()

  # Return all options if 'null' is passed
  # Return default values for unspecified options 
  # Return an object of all requested options, if passed an array
  getOption: (optionNameOrArr) ->
    if _.isNull(optionNameOrArr)
      _.defaults(@option, @defaultOption)
    else if _.isString(optionNameOrArr)
      name = optionNameOrArr
      @option[name] || @defaultOption[name]
    else
      nameArr = optionNameOrArr
      valArr = _.map(nameArr, @getOption, @)
      _.zipObject(nameArr, valArr)

  # Return all state if 'null' is passed
  # Return default values for unspecified states
  # Return an object of all requested states, if passed an array
  getState: (stateNameOrArr) ->
    if _.isNull(stateNameOrArr)
      _.defaults(@state, @defaultState)
    else if _.isString(stateNameOrArr)
      name = stateNameOrArr
      @state[name] || @defaultState[name]
    else
      nameArr = stateNameOrArr
      valArr = _.map(nameArr, @getState, @)
      _.zipObject(nameArr, valArr)
  

