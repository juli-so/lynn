# ---------------------------------------------------------------------------- #
#                                                                              #
# Store window and tab info here for easier retrieval                          #
#                                                                              #
# - All WinTab methods are bound to itself for easier chaining                 #
#                                                                              #
# ---------------------------------------------------------------------------- #
#                                                                              #
# Note: Do not use chrome.windows.getCurrent to get current window.            #
# From https://developer.chrome.com/extensions/windows                         #
#                                                                              #
#   The current window is the window that contains the code that is currently  #
#   executing. It's important to realize that this can be different from the   #
#   topmost or focused window.                                                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

WinTab =
  winArr: []
  currWin: {}

  # ------------------------------------------------------------
  # Helper
  # ------------------------------------------------------------

  _isNCTab: (tab) ->
    not _.startsWith(tab.url, 'chrome')

  _isNCWin: (window) ->
    _.some(window.tabs, @_isNCTab)

  _g_NCWinArr: ->
    _.filter(@winArr, @_isNCWin)

  _c_g_AllWin: (cb) ->
    chrome.windows.getAll { populate: yes }, (winArr) -> cb(winArr)

  _update: (winArr) ->
    @winArr = winArr
    @currWin = _.find(winArr, 'focused')

  _log: ->

  # ------------------------------------------------------------
  # Init & Listen
  # ------------------------------------------------------------

  init: ->
    @_c_g_AllWin (winArr) =>
      @_update()
      @listen()

  listen: ->
    c_win = chrome.windows
    c_tab = chrome.tabs

    # ----------------------------------------------------------
    # Window events
    # ----------------------------------------------------------

    c_win.onCreated.addListener (win) =>
      @_c_g_AllWin(@_update)

    # Will not be triggered if the removed window is the last one
    c_win.onRemoved.addListener (winId) =>
      @_c_g_AllWin(@_update)

    c_win.onFocusChanged.addListener (winId) =>
      @_c_g_AllWin(@_update)

    # ----------------------------------------------------------
    # Tab events
    # ----------------------------------------------------------

    c_tab.onCreated.addListener (tab) =>
      @_c_g_AllWin(@_update)

    c_tab.onUpdated.addListener (tabId, changeInfo, tab) =>
      @_c_g_AllWin(@_update)

    c_tab.onRemoved.addListener (tab) =>
      @_c_g_AllWin(@_update)

  # ------------------------------------------------------------
  # Getters
  # ------------------------------------------------------------

  g_currWinTabArr: (NC = yes) ->
    if NC
      _.filter(@currWin.tabs, @_isNCTab)
    else
      @currWin.tabs

  # Even if currTab is a NC tab, return it.
  g_currTab: ->
    _.find(@g_currWinTabArr(no), 'active')


  g_allTabArr: (NC = yes) ->
    orderedWinArr = _.without(@winArr, @currWin)
    orderedWinArr.unshift(@currWin)

    allTabArr = _.flatten(_.pluck(orderedWinArr, 'tabs'))
    if NC
      _.filter(allTabArr, @_isNCTab)
    else
      allTabArr

_.bindAll(WinTab)

