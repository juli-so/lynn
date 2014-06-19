# Message to & from backend

Message =
  port: {}

  init: ->
    @port = chrome.runtime.connect { }

  postMessage: (message) ->
    @port.postMessage message

  addListener: (callback) ->
    @port.onMessage.addListener callback
