# Process async responses from backend

Listener =
  callbackMap: {} # res -> callback

  init: ->
    Message.addListener (message) =>
      if @callbackMap[message.res]
        @callbackMap[message.res](message)

  listen: (res, callback) ->
    @callbackMap[res] = callback

  # Also make the request after the listener is set 
  listenOnce: (res, reqObj, callback) ->
    @listen res, (message) =>
      callback(message)
      @stopListen(res)

    defaultReqObj = { req: res }
    Message.postMessage(_.assign(defaultReqObj, reqObj))

  stopListen: (res) ->
    delete @callbackMap[res]
