# Processes async responses from backend

Listener =
  callbackMap: {} # response -> callback

  init: ->
    Message.addListener (message) =>
      if @callbackMap[message.response]
        @callbackMap[message.response](message)

  setListener: (response, callback) ->
    @callbackMap[response] = callback

  removeListener: (response) ->
    delete @callbackMap[response]
