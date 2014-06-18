# Defines Actions requested to be performed by front-end
# All methods take a single argument 'message', return

Action =
  search: (message) ->
    response: 'search'
    result: Bookmark.find(message.input)
  
  # ------------------------------------------------------------

  # Opening bookmarks
  open: (message) ->
    if message.node
      chrome.tabs.create
        url: message.node.url
        active: message.option.active
    else
      _.forEach message.nodeArray, (node) ->
        chrome.tabs.create
          url: node.url
          active: message.option.active

    { response: 'open' }

  openInNewWindow: (message) ->
    if message.node
      url = message.node.url
    else
      url = _.pluck(message.nodeArray, 'url')

    chrome.windows.create
      url: url
      incognito: message.option.incognito

    { response: 'openInNewWindow' }

  # ------------------------------------------------------------

  addTag: (message) ->
    if message.tag
      Bookmark.addTag(message.node, message.tag)
    else
      _.forEach message.tagArray, (tag) ->
        Bookmark.addTag(message.node, tag)

    { response: 'addTag' }
