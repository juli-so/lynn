# Processes async responses from backend

Listener =
  callbackMap: {} # response -> callback

  init: ->
    Message.addListener (message) ->
      if message.response and message.response[0..1] is 'a_'
        if @callbackMap[message.response]
          @callbackMap[message.response](message)

  setListener: (response, callback) ->
    @callbackMap[response] = callback
