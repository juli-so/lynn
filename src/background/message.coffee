# Handles messages from frontend by taking action & sending back messages
# Actions are defined in action.coffee

Message =
  init: ->
    chrome.runtime.onConnect.addListener (port) =>
      @addListener port

  # Listen to message from front
  # Messages are expected to be in this form
  # message =
  #   request: Action[request]
  #   --
  #   |
  #   custom objects needed to be carried over for action
  #   differs from action to action
  #   |
  #   --
  #   option:
  #     optionA: yes
  #     optionB: no
  addListener: (port) ->
    port.onMessage.addListener (message) =>
      port.postMessage(Action[message.request](message))
