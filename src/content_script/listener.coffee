# Processes async responses from backend

Listener =
  callbackMap: {} # response -> callback

  init: ->
    Message.addListener (message) =>
      if @callbackMap[message.response]
        @callbackMap[message.response](message)

  setListener: (response, callback) ->
    @callbackMap[response] = callback

  setOneTimeListener: (response, callback) ->
    @setListener response, (message) =>
      callback(message)
      @removeListener(response)

  removeListener: (response) ->
    delete @callbackMap[response]
