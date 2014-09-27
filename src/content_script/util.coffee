# Something more than one object needs

Util =
  isTag: (tag) ->
    tag[0] is '#' or tag[0] is '@'

  isntTag: (tag) ->
    not @isTag(tag)

  startsWith: (str, start) ->
    str.lastIndexOf(start, 0) is 0

  # Empty tagArr
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
    
  # ------------------------------------------------------------

  getCaretPosition: ->
    e = document.getElementById('lynn_console')
    [e.selectionStart, e.selectionEnd]

  setCaretRange: (start, end) ->
    e = document.getElementById('lynn_console')
    e.setSelectionRange(start, end)
