# Something more than one object needs

Util =
  isTag: (tag) ->
    tag[0] is '#' or tag[0] is '@'

  isntTag: (tag) ->
    not @isTag(tag)

  # Empty tagArray
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
    
