# ---------------------------------------------------------------------------- #
#                                                                              #
# Helper for getting Win/Tab information from chrome                           #
#                                                                              #
# - NC = Non-Chrome                                                            #
# - All WinTab methods are bound to itself for easier chaining                 #
#                                                                              #
# ---------------------------------------------------------------------------- #
#                                                                              #
# Note: Do not use chrome.windows.getCurrent to get current window             #
#                  chrome.tabs.getCurrent    to get current tab                #
#                                                                              #
#   The current window/tab is the window/tab that contains the code that is    #
#   currently executing. It's important to realize that this can be different  #
#   from the topmost or focused window/tab.                                    #
#                                                                              #
# ---------------------------------------------------------------------------- #

WinTab =
  # ------------------------------------------------------------
  # Helper
  # ------------------------------------------------------------

  _isNCTab: (tab) ->
    not _.startsWith(tab.url, 'chrome')

  # Have at least one tab that is NC
  _isNCWin: (window) ->
    _.any(window.tabs, @_isNCTab)

  # ------------------------------------------------------------
  # Tab Getter
  # ------------------------------------------------------------

  getCurrTab: (cb) ->
    chrome.tabs.query { currentWindow: yes }, (tabArr) ->
      cb(_.find(tabArr, 'active'))

  getAllTab: (NC = yes, cb = _.noop) ->
    chrome.windows.getAll { populate: yes }, (winArr) =>
      currWin = _.find(winArr, 'focused')
      currTab = _.find(currWin.tabs, 'active')

      # Tabs in currWin always go first
      orderedWinArr = _.without(winArr, currWin)
      orderedWinArr.unshift(currWin)

      allTabArr        = _.flatten(_.pluck(orderedWinArr, 'tabs'))
      currWinTabArr    = currWin.tabs
      nonCurrWinTabArr = _.difference(allTabArr, currWinTabArr)

      # Filter out loading pages
      loadingComplete  = (tab) -> tab.status is 'complete'
      allTabArr        = _.filter(allTabArr,        loadingComplete)
      currWinTabArr    = _.filter(currWinTabArr,    loadingComplete)
      nonCurrWinTabArr = _.filter(nonCurrWinTabArr, loadingComplete)

      if NC
        allTabArr        = _.filter(allTabArr,        @_isNCTab)
        currWinTabArr    = _.filter(currWinTabArr,    @_isNCTab)
        nonCurrWinTabArr = _.filter(nonCurrWinTabArr, @_isNCTab)

      cb({ currTab, allTabArr, currWinTabArr, nonCurrWinTabArr })

  getCurrWinTabArr: (NC = yes, cb = _.noop) ->
    chrome.tabs.query { currentWindow: yes, status: "complete" }, (tabArr) ->
      tabArr = _.filter(tabArr, @_isNCTab) if NC
      cb(tabArr)

  # ------------------------------------------------------------
  # Win Getter
  # ------------------------------------------------------------

  getCurrWin: (cb) ->
    chrome.windows.getCurrent({ populate: yes }, cb)

  getAllWin: (cb) ->
    chrome.windows.getAll({ populate: yes }, cb)


# Allow FP chaining
_.bindAll(WinTab)

