# ---------------------------------------------------------------------------- #
#                                                                              #
# Store / Get state & option to chrome.storage                                 #
# For background only                                                          #
#                                                                              #
# ---------------------------------------------------------------------------- #

CStorage =
  bgOption: {}
  bgState : {}

  # Use callback to ensure sequence of operation
  init: (callback) ->
    chrome.storage.local.get null, (storObj) =>
      @bgOption = storObj['bgOption'] || {}
      @bgState  = storObj['bgState' ] || {}
      callback()

  clear: ->
    setObj =
      bgOption: {}
      bgState : {}

    chrome.storage.local.set setObj, =>
      @bgOption = {}
      @bgState  = {}

  setOption: (option, val) ->
    @bgOption[option] = val
    chrome.storage.local.set { bgOption: @bgOption }

  setState: (state, val) ->
    @bgState[state] = val
    chrome.storage.local.set { bgState: @bgState }

