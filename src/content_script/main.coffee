$(->
  Message.init()
  Listener.init()

  # Init UI
  $mountPoint = $("<div id='lynn_container'>")
  $('body').prepend($mountPoint)

  Listener.setOneTimeListener 'getOption', (message) ->
    React.renderComponent Lynn({storageObject: message.storageObject}),
      $mountPoint[0]

  Message.postMessage
    request: 'getOption'
)
