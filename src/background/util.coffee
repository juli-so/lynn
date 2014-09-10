Util =
  tabToNode: (tabOrTabArray) ->
    if not _.isArray(tabOrTabArray)
      tab = tabOrTabArray

      title: tab.title
      url: tab.url
      tagArray: []
    else
      tabArray = tabOrTabArray

      _.map tabArray, (tab) =>
        @tabToNode(tab)
    
  startsWith: (str, start) ->
    str.lastIndexOf(start, 0) is 0

  ciContains: (str, fragment) ->
    str.toLowerCase().indexOf(fragment.toLowerCase()) isnt -1

  numToString: (num) ->
    '' + num

  toSimpleBookmark: (bookmark) ->
    title: bookmark.title
    url: bookmark.url


