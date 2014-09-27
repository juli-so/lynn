# Handles messages from frontend by taking action & sending back messages
# Actions are defined in action.coffee

Message =
  init: ->
    chrome.runtime.onConnect.addListener (port) =>
      port.onMessage.addListener (message) =>
        # pass port to it in case it needs to send additional responses
        resMsg = Action[message.req](message, port)

        if resMsg and resMsg.res
          port.postMessage(resMsg)
