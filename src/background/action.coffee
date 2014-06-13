# Defines Actions requested to be performed by front-end

Action =
  # Opening webpages
  openBookmark: (message) ->
    chrome.tabs.create
      url: message.node.url
      active: message.option.active
    { response: 'openBookmark' }


