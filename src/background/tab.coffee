################################################################
#
# Whenever a tab is
#   - created
#   - updated
#   - removed
# update the Tab object
#
# This allows synchronous call for getting tab info
#
################################################################

Tab =
  tabPool: {} # tab ID -> tab
  current: {}

  init: ->
    chrome.tabs.query {}, (tabs) =>
      _.forEach tabs, (tab) =>
        @tabPool[tab.id] = tab

    chrome.tabs.onCreated.addListener (tab) =>
      console.log 'created'
      @tabPool[tab.id] = tab

    chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) =>
      if changeInfo.url
        console.log 'updated'
        @tabPool[tabId] = tab

    chrome.tabs.onRemoved.addListener (tabId) =>
      console.log 'removed'
      delete @tabPool[tabId]

    # ----------------------------------------------------------

    chrome.tabs.query { active: yes, currentWindow: yes }, (tabs) =>
      @current = tabs[0]

    chrome.tabs.onActivated.addListener (activeInfo) =>
      @current = @tabPool[activeInfo.tabId]

    chrome.windows.onFocusChanged.addListener =>
      chrome.tabs.query { active: yes, currentWindow: yes }, (tabs) =>
        @current = tabs[0]
