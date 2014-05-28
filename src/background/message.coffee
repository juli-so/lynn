# Handles messages from frontend & execute commands appropriately

Message =
  init: ->
    chrome.runtime.onConnect.addListener (port) =>
      @addListener port

  # Listen to message from front
  # Define stucture of messages sent to & from front
  addListener: (port) ->
    port.onMessage.addListener (message) =>
      switch message.request
        when 'search'
          port.postMessage
            response: 'search'
            result: Bookmark.find(Completion.preprocess message.command)
        when 'open'
          chrome.tabs.create url: message.url, active: false
