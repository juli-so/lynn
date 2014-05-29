# Handles messages from frontend 
# Pass messages to Command, which take actions & generate responses
# Command then pass the response using Message

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
          openAllUnderDir = (dirNode) ->
            _.forEach dirNode.children, (child) ->
              if child.isBookmark
                chrome.tabs.create url: child.url, active: false
              else
                openAllUnderDir(child)

          if message.node.isBookmark
            chrome.tabs.create url: message.node.url, active: false
          else
            openAllUnderDir message.node

