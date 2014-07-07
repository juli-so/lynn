# Handles messages from frontend by taking action & sending back messages
# Actions are defined in action.coffee

Message =
  init: ->
    chrome.runtime.onConnect.addListener (port) =>
      port.onMessage.addListener (message) =>
        # pass port to it in case it needs to send additional responses
        responseMessage = Action[message.request](message, port)

        if responseMessage and responseMessage.response
          port.postMessage(responseMessage)
