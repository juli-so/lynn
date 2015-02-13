# ---------------------------------------------------------------------------- #
#                                                                              #
# Utility functions                                                            #
#                                                                              #
# ---------------------------------------------------------------------------- #

Util =
  # Look like a tag
  # Used for checking whether input is valid in frontend
  isLikeTag: (tag) ->
    tag[0] is '#' or tag[0] is '@'

  # '#' '@' tags with no text are not allowed
  # Used for adding tags in backend
  isTag: (tag) ->
    tag.length > 1 and @isLikeTag(tag)

  isntTag: (tag) ->
    not @isTag(tag)

  # ------------------------------------------------------------
  # To be thrown away
  # ------------------------------------------------------------

  tabToNode: (tabOrTabArr) ->
    if not _.isArray(tabOrTabArr)
      tab = tabOrTabArr

      title: tab.title
      url: tab.url
      tagArr: []
    else
      tabArr = tabOrTabArr

      _.map tabArr, (tab) =>
        @tabToNode(tab)
    
  numToString: (num) ->
    '' + num

  # Used when re-creating bookmark during bookmark recovery
  toSimpleBookmark: (bookmark) ->
    title: bookmark.title
    url: bookmark.url

  getCaretPosition: ->
    e = document.getElementById('lynn_console')
    [e.selectionStart, e.selectionEnd]

  setCaretRange: (start, end) ->
    e = document.getElementById('lynn_console')
    e.setSelectionRange(start, end)


