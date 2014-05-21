# Message to & from backend

Message =
  port: {}

  init: ->
    @port = chrome.runtime.connect { }

  postMessage: (msg) ->
    @port.postMessage msg

  addListener: (callback) ->
    @port.onMessage.addListener callback
