# Manages window
# Non-chrome window: window that has tabs whose urls don't start with chrome

Window =
  windowArray: []
  nonChromeWindowArray: []

  lastWindowTabArray: []

  init: ->
    chrome.storage.sync.get 'lastWindowTabArray', (storageObject) =>
      @lastWindowTabArray = storageObject.lastWindowTabArray || []

    @updateWindowArray()

    chrome.windows.onCreated.addListener (window) =>
      @updateWindowArray()

    chrome.windows.onRemoved.addListener (windowId) =>
      # If the removed window is a non-chrome window
      # Put its tabs as 'lastWindowTabArray'
      _.forEach @nonChromeWindowArray, (window) =>
        if windowId is window.id
          lastWindowTabArray = _.filter window.tabs, (tab) =>
            not Util.startsWith(tab.url, 'chrome')

          chrome.storage.sync.set { lastWindowTabArray }
          @lastWindowTabArray = lastWindowTabArray

      @updateWindowArray()

    chrome.tabs.onUpdated.addListener =>
      @updateWindowArray()

  _isNonChromeWindow: (window) ->
    _.some window.tabs, (tab) =>
      not Util.startsWith(tab.url, 'chrome')

  updateWindowArray: ->
    chrome.windows.getAll { populate: yes }, (windowArray) =>
      @windowArray = windowArray
      @nonChromeWindowArray = @getNonChromeWindowArray()

  getNonChromeWindowArray: ->
    _.filter @windowArray, (window) =>
      @_isNonChromeWindow(window)

  _log: ->
    console.log '### windowArray: '
    _.forEach @windowArray, (window) ->
      console.log "Window id #{window.id}"
      _.forEach window.tabs, (tab) ->
        console.log "  #{tab.title}"
    console.log '### nonChromeWindowArray: '
    _.forEach @nonChromeWindowArray, (window) ->
      console.log "Window id #{window.id}"
      _.forEach window.tabs, (tab) ->
        console.log "  #{tab.title}"
    console.log '### lastWindowTabArray: '
    _.forEach @lastWindowTabArray, (tab) ->
      console.log "Tab id is #{tab.id}"
      console.log "  #{tab.title}"
