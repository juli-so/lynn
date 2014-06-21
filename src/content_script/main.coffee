$(->
  Message.init()
  Listener.init()

  # Init UI
  $mountPoint = $("<div id='lynn_container'>")
  $('body').prepend($mountPoint)
  React.renderComponent Lynn(), $mountPoint[0]

)
