Util =
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
    
  startsWith: (str, start) ->
    str.lastIndexOf(start, 0) is 0

  ciStartsWith: (str, start) ->
    @startsWith(str.toLowerCase(), start.toLowerCase())

  ciContains: (str, fragment) ->
    str.toLowerCase().indexOf(fragment.toLowerCase()) isnt -1

  numToString: (num) ->
    '' + num

  toSimpleBookmark: (bookmark) ->
    title: bookmark.title
    url: bookmark.url


