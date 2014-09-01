# Process async responses from backend

Listener =
  callbackMap: {} # response -> callback

  init: ->
    Message.addListener (message) =>
      if @callbackMap[message.response]
        @callbackMap[message.response](message)

  listen: (response, callback) ->
    @callbackMap[response] = callback

  # Also make the request after the listener is set 
  listenOnce: (response, requestObject, callback) ->
    @listen response, (message) =>
      callback(message)
      @stopListen(response)

    defaultRequestObject = { request: response }
    Message.postMessage(_.assign(defaultRequestObject, requestObject))
    console.log _.assign(defaultRequestObject, requestObject)

  stopListen: (response) ->
    delete @callbackMap[response]
