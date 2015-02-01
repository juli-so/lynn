# ---------------------------------------------------------------------------- #
#                                                                              #
# Process async responses from backend                                         #
#                                                                              #
# ---------------------------------------------------------------------------- #

Listener =
  callbackMap: {} # res -> callback

  init: ->
    Message.addListener (message) =>
      if @callbackMap[message.res]
        @callbackMap[message.res](message)

  listen: (res, callback) ->
    @callbackMap[res] = callback

  # Also make the request after the listener is set 
  # If listener is already set, use the provided listener, but restore to the
  # old listener after done
  listenOnce: (res, reqObj, callback) ->
    if @callbackMap[res]
      oldCallback = @callbackMap[res]

    @listen res, (message) =>
      callback(message)

      if oldCallback
        @listen(res, oldCallback)
      else
        @stopListen(res)

    defaultReqObj = { req: res }
    Message.postMessage(_.assign(defaultReqObj, reqObj))

  stopListen: (res) ->
    delete @callbackMap[res]
