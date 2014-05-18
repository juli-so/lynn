##############################################################################
# 
# Backend engine for Marniak
#
##############################################################################

Bookmark.init(-> Completion.init())

chrome.runtime.onConnect.addListener((port) ->
  port.onMessage.addListener((message) ->
    if message.request == 'search'
      port.postMessage({
        response: 'search',
        result: Bookmark.find(Completion.preprocess(message.command))
      })

    if message.request == 'open'
      chrome.tabs.create({url: message.url, active: false})
  )
)
