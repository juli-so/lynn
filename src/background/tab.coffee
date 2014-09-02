Tab =
  # ordered, current window's tabs are first
  tabArray: []
  # a chrome tab
  current: {}

  currentWindowId: 0

  init: ->
    # get window id first for ordering purpose
    chrome.windows.getCurrent (window) =>
      @currentWindowId = window.id

      @updateTabArray()
      @updateCurrentTab()

    chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) =>
      return if Util.startsWith(tab.url, 'chrome')

      if changeInfo.status or changeInfo.url
        @updateTabArray()
      if tabId is @current.id
        @updateCurrentTab()

    chrome.tabs.onRemoved.addListener (tabId) =>
      @updateCurrentTab() if tabId is @current.id

      @updateTabArray()

    chrome.tabs.onActivated.addListener =>
      @updateCurrentTab()

    chrome.windows.onRemoved.addListener =>
      @updateCurrentTab()
      @updateTabArray()

    chrome.windows.onFocusChanged.addListener (newWindowId) =>
      @updateCurrentTab()
      @currentWindowId = newWindowId
      @updateTabArray()

  _filterChromeTab: (allTabArray) ->
    _.filter allTabArray, (tab) =>
      not Util.startsWith(tab.url, 'chrome')

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

  getCurrentWindowTabArray: ->
    _.filter @tabArray, (tab) =>
      tab.windowId is @current.windowId

  _log: ->
    console.log 'Current window id: ', @currentWindowId
    console.log 'Current tab:'
    console.log 'Title: ', @current.title
    console.log 'All tabs:'
    _.forEach @tabArray, (tab) ->
      console.log 'Title: ', tab.title
