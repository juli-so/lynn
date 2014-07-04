# Handles messages from frontend by taking action & sending back messages
# Actions are defined in action.coffee

Message =
  init: ->
    chrome.runtime.onConnect.addListener (port) =>
      port.onMessage.addListener (message) =>
        port.postMessage(Action[message.request](message, port))
