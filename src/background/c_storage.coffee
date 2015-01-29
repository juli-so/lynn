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

  setOption: (option, val, cb) ->
    @option[option] = val
    chrome.storage.local.set { option: @option }, ->
      if cb
        cb()

  setState: (state, val, cb) ->
    @state[state] = val
    chrome.storage.local.set { state: @state }, ->
      if cb
        cb()

  # Return all options if 'null' is passed
  # Return default values for unspecified options 
  getOption: (option) ->
    if _.isNull(option)
      _.defaults(@option, @defaultOption)
    else
      @option[option] || @defaultOption[option]

  # Return all state if 'null' is passed
  # Return default values for unspecified states
  getState: (state) ->
    if _.isNull(state)
      _.defaults(@state, @defaultState)
    else
      @state[state] || @defaultState[state]
  

