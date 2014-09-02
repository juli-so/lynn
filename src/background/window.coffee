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
    console.log 'windowArray: ', @windowArray
    console.log 'nonChromeWindowArray: ', @nonChromeWindowArray
    console.log 'lastWindowTabArray: ', @lastWindowTabArray
