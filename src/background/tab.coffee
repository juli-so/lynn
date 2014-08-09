Tab =
  # ordered
  tabArray: []

  # this can be a chrome tab
  current: {}

  currentWindowId: 0

  init: ->
    # get window id first for ordering purpose
    chrome.windows.getCurrent (window) =>
      @currentWindowId = window.id

      @updateTabArray()
      @updateCurrentTab()

    chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) =>
      return if @_startsWith(tab.url, 'chrome')

      if changeInfo.status or changeInfo.url
        @updateTabArray()
      if tabId is @current.id
        @updateCurrentTab()

    chrome.tabs.onRemoved.addListener (tabId) =>
      @updateCurrentTab() if tabId is @current.id

      @updateTabArray()

    chrome.tabs.onActivated.addListener =>
      @updateCurrentTab()

    chrome.windows.onFocusChanged.addListener (newWindowId) =>
      @updateCurrentTab()
      @currentWindowId = newWindowId
      @updateTabArray()

  _startsWith: (str, start) ->
    str.lastIndexOf(start, 0) is 0

  _filterChromeTab: (allTabArray) ->
    _.filter allTabArray, (tab) =>
      not @_startsWith(tab.url, 'chrome')

  updateTabArray: ->
    orderedWindowArray = []
    chrome.windows.getAll { populate: yes }, (windowArray) =>
      _.forEach windowArray, (window) =>
        if window.id is @currentWindowId
          orderedWindowArray.unshift(window)
        else
          orderedWindowArray.push(window)

      allTabArray = _.flatten(_.pluck(orderedWindowArray, 'tabs'), yes)
      @tabArray = @_filterChromeTab(allTabArray)

  updateCurrentTab: ->
    chrome.tabs.query { active: yes, currentWindow: yes }, (tabArray) =>
      @current = tabArray[0]

  _log: ->
    console.log 'current window id', @currentWindowId
    console.log 'current'
    console.log 'title: ', @current.title
    console.log 'all'
    _.forEach @tabArray, (tab) ->
      console.log 'title: ', tab.title
