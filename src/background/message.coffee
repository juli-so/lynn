# ---------------------------------------------------------------------------- #
#                                                                              #
# Handle messages by taking actions & sending back messages                    #
#                                                                              #
# ---------------------------------------------------------------------------- #

Message =
  init: ->
    chrome.runtime.onConnect.addListener (port) =>
      port.onMessage.addListener (message) =>
        # Optionally let the action function to finish async
        done = (resObj) ->
          defaultResObj = { res: message.req }
          port.postMessage(_.assign(defaultResObj, resObj || {}))

        resMsg = Action[message.req](message, done)

        if resMsg and resMsg.res
          port.postMessage(resMsg)
